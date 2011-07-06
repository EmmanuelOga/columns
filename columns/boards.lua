local K = require("game.constants")
local gems = require "columns.gems"
local dynArray = require "utils.dynArray"
local floor = math.floor
local pairs, ipairs = pairs, ipairs

local function board(data)
  assert(data.w and data.h, "board requires both w and h")

  local self = data or {}

  local grid = dynArray() -- width x height grid.

  -- used by the matcher algorithm to handle all directions in a more generic way
  local stripes = { vert = {}, horz = {}, upDiag = {}, downDiag = {} }

  local function fillStripes()
    local function stripe(table, x, y, xDelta, yDelta)
      local current = {}
      while x > 0 and x <= self.w and y > 0 and y <= self.h do
        current[#current + 1] = {x=x, y=y}
        x = x + xDelta ; y = y + yDelta
      end
      if #current > 2 then table[#table + 1] = current end
    end

    for y = 1,  self.h do stripe(stripes.horz, 1, y, 1, 0) end
    for x = 1,  self.w do stripe(stripes.vert, x, 1, 0, 1) end

    for x0 = 1, self.w do stripe(stripes.downDiag, x0, 1, 1, 1) end
    for y0 = 1, self.h do stripe(stripes.downDiag, 1, y0, 1, 1) end

    for x0 = 1, self.w do stripe(stripes.upDiag, x0, self.h, 1, -1) end
    for y0 = 1, self.h do stripe(stripes.upDiag, 1,  y0,     1, -1) end
  end

  fillStripes()

  self.stripes = stripes

  self.get = function(x, y)
    if type(x) == "table" then y = x.y; x = x.x end
    return grid[x][y]
  end

  self.set = function(x, y, val, ...)
    if type(val) == "string" then
      gem = gems[val](...)
    else
      gem = val or gems.hole()
    end
    grid[x][y] = gem
    return gem
  end

  self.isFree = function(x, y)
    if y > self.h or y < 1 or x > self.w or x < 1 then
      return false
    else
      return self.get(x, y).hole
    end
  end

  self.allCoordinates = function(first)
    local x, y = 0, first or 1
    return function()
      while not(x == self.w and y == self.h) do
        x = x + 1
        if x > self.w then x, y = 1, y + 1 end
        return x, y, grid[x][y]
      end
    end
  end

  self.area = function()
    return self.w * self.h
  end

  self.clear = function(val)
    for x, y in self.allCoordinates() do self.set(x, y, val or gems.hole()) end
  end

  self.stats = function()
    local stats, count = {}, 0
    for i = 1, K.NUM_GEMS do stats[i] = 0 end
    for x, y, b in self.allCoordinates() do
      if b.color then
        count = count + 1
        stats[b.color] = stats[b.color] + 1
      end
    end
    if count ~= 0 then
      for i = 1, K.NUM_GEMS do stats[i] = stats[i] * 100 / count end
    end
    return stats
  end

  self.selectedCount = function()
    local count = 0
    for x, y, b in self.allCoordinates() do if ( not b.destroy or ( b.stays and b.stays > 1 ) ) and b.selected then count = count + 1 end end
    return count
  end

  self.toDestroyLeft = function()
    local count = 0
    for x, y, b in self.allCoordinates() do if b.destroy then count = count + 1 end end
    return count
  end

  ------------------------------------------------------------------------------

  self.findMatches = function(kind, minLength)
    local b
    local totalStreaks = 0 -- used later to calculate combos

    -- first go through the board and flag the lines found as "matched"
    for _, coords in ipairs(stripes[kind]) do
      local maxIndex = #coords ; local i = 1

      while i < maxIndex do
        local i0 = i; local streak = 1
        while i < maxIndex and gems.isMatch(self, coords, i) do
          i = i + 1 ; streak = streak + 1
        end
        if streak >= minLength then
          totalStreaks = totalStreaks + 1
          for j = i0, i do
            b = self.get(coords[j])
            if not b.hole then b.matched = true end
          end
        end
        i = i + 1
      end
    end

    local totalMatches = 0

    -- look for burn gems and process them.
    for x, y, b in self.allCoordinates() do
      if not b.destroy and b.burn then gems.processBurn(self, x, y) end
    end

    -- because gems can have the side effect of mark other gems as matched,
    -- we'll now iterate over the board looking for new matched (e.g. because of line bombs)
    local function processAll()
      local matches = 0
      --for x, y, b in self.allCoordinates() do if b.fixed then b.destroy = nil end end -- can happen on board up/down
      for x, y, b in self.allCoordinates() do
        if not b.destroy and b.matched then
          matches = matches + 1
          b.destroy = K.BASE_DESTROY_TIME + matches * K.NORMAL_DESTROY_TIME -- later, it will be used to destroy things following a timer.
          if b.arrowMatched then b.destroy = b.destroy + b.arrowSequence end
          if b.bomb then gems.processBomb(self, x, y) end
        end
      end
      return matches
    end

    -- ok, now we actually mark gems for destroy. Repeat until no further matches are found
    local matches = processAll(); totalMatches = totalMatches + matches
    while matches > 0 do
      matches = processAll(); totalMatches = totalMatches + matches
      if matches > 0 then
        totalStreaks = totalStreaks + 1 -- Let's just count each chain reaction as an additional streak.
      end
    end

    -- clear matches once we are done (b.destroy is the important thing)
    for x, y, b in self.allCoordinates() do b.matched = nil end

    return totalMatches, totalStreaks
  end

  -- clear every gem marked for destroy.
  self.destroyMatches = function(dt, callback)
    local destroys = 0
    for x, y, b in self.allCoordinates() do
      if b.destroy and b.destroy > 0 then
        b.destroy = b.destroy - dt

        if b.destroy < 0.8 then callback(x, y, b, b.destroy <= 0) end
        if b.destroy <= 0 then
          if b.stays and b.stays > 1 then
            b.stays = b.stays - 1
            b.destroy = nil
            b.arrowMatched = nil
          else
            destroys = destroys + 1
            self.set(x, y)
          end
        end
      end
    end
    return destroys
  end

  -- returns wether a position in the board will be moved by the
  -- bubbleUpHoles function or not.
  self.isFloating = function(x, y)
    if type(x) == "table" then y = x.y; x = x.x end
    if y == self.h then return false
    else
      for v = y, self.h do
        local b = self.get(x, v)
        if b and b.fixed then return false
        elseif b and b.hole then return true
        end
      end
      return false
    end
  end

  -- returns true if any gem needs to be bubbled up, false otherwise.
  self.hasUnestableColumns = function()
    local current, following
    for x = 1, self.w do
      for y = 1, self.h - 1 do
        current = self.get(x, y)
        following = self.get(x, y + 1)
        if (not current.hole and not current.fixed and following.hole) or current.destroy then return true end
      end
    end
    return false
  end

  -- bubble up holes of every column of the board
  self.bubbleUpHoles = function(dt)
    local get, set = self.get, self.set
    local c, f, n, fh
    for x = 1, self.w do
      fh = self.h
      for y = self.h - 1, 1, -1 do
        c = get(x, y)
        if not (c.hole or c.fixed or c.destroy) then
          n = fh; f = get(x, n)
          while not f.hole and n ~= y do n = n - 1; f = get(x, n) end
          if n ~= y and f.hole then
            set(x, n, c); set(x, y, f); fh = n - 1
          else
            fh = y - 1
          end
        elseif c.fixed then fh = y - 1
        end
      end
    end
  end

  self.lastLineIsFixed = function()
    for x = 1, self.w do
      if not self.get(x, self.h).fixed then return false end
    end
    return true
  end

  -- moves the floor up and returns whether it make the user lost or not.
  self.floorUp = function()
    local ret = true
    for x = 1, self.w do if not self.get(x, 1).hole then ret = false; break end end
    for x = 1, self.w do
      for y = 1, self.h - 1 do self.set(x, y, self.get(x, y + 1)) end
      self.set(x, self.h, gems.fixed())
    end
    return ret
  end

  self.floorDown = function()
    if self.lastLineIsFixed() then
      for x = 1, self.w do
        for y = self.h, 2, -1 do self.set(x, y, self.get(x, y - 1)) end
        self.set(x, 1, gems.hole())
      end
    end
  end

  -- you know, it is a little bit dangerous.
  self.dangerous = function()
    local get = self.get
    for x, y in self.allCoordinates() do
      if y > K.COLUMN_HEIGHT then return false end
      if not get(x, y).hole then return true end
    end
    return false
  end

  self.clear()

  return self
end

return board
