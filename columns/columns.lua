local floor = math.floor

local function column(data)
  local self = data or {}

  self.left = 1 -- can be used to keep track of time until is pushed down.

  self.rotateUp = function()
    self[1], self[2], self[3] = self[2], self[3], self[1]
  end

  self.rotateDown = function()
    self[1], self[2], self[3] = self[3], self[1], self[2]
  end

  self.pushLeft = function()
    if self.x > 1 then
      local nx, ny, isFree  = self.x - 1, self.y, self.board.isFree
      if self.y == 1 or (isFree(nx, ny) and isFree(nx, ny + 1) and isFree(nx, ny + 2)) then
        self.x = nx
        return true
      end
    end
    return false
  end

  self.pushRight = function()
    if self.x < self.board.w then
      local nx, ny, isFree = self.x + 1, self.y, self.board.isFree
      if self.y == 1 or (isFree(nx, ny) and isFree(nx, ny + 1) and isFree(nx, ny + 2)) then
        self.x = nx
        return true
      end
    end
    return false
  end

  self.pushDown = function(dt)
    self.left = 1 -- reset time left to fall (used to smooth column fall down)

    if self.y < (self.board.h - self.h + 1) and self.board.isFree(self.x, self.y + self.h) then
      self.y = self.y + 1
      self.laying = 0
      self.offset = 0
      return not self.board.isFree(self.x, self.y + self.h)
    else
      self.laying = self.laying + (dt or 0.1)
    end
  end

  self.isLaying = function()
    return not self.board.isFree(self.x, self.y + 3)
  end

  self.update = function(dt)
    if self.isLaying() then
      self.laying = self.laying + dt
    else
      self.laying = 0
    end
  end

  self.pushUp = function()
    self.left = 1 -- reset time left to fall
    if self.y > 1 then
      self.y = self.y - 1
      return self.y
    else
      return false
    end
  end

  self.allCoordinates = function()
    local counter = 0

    return function()
      counter = counter + 1
      local gem = self[counter]
      if gem then return self.x, counter + self.y - 1, gem end
    end
  end

  -- places the column, or returns false if it could not (no free space for the
  -- column on the board) which signals game over.
  self.place = function()
    if self.fits() then
      local x, y, board = self.x, self.y - 1, self.board
      for i = 1, self.h do board.set(x, y + i, self[i]) end
      return true
    end
    return false
  end

  -- checks whether the column can be fitter in the current location.
  self.fits = function()
    local x, y, board = self.x, self.y - 1, self.board
    for i = 1, self.h do if not board.get(x, y + i).hole then return false end end
    return true
  end

  self.h = 3 -- three elements column
  self.x = self.board and floor(self.board.w / 2 + 0.5) or 1 -- put gem in the middle by default.
  self.y = 1
  self.laying = 0 -- time that has been laying

  return self
end

return column
