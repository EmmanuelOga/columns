local LG = love.graphics
local K = require("game.constants")

local chunky = require('game.render.chunky')
local sounds = require('game.sounds')

local function scoreKeeper()
  local self = {
    matches = 0,
    levelMatches = 0,
    longMatches = 0,
    multiple = 0,
    score = 0,
    combos = {},
    elapsedLevel = 0,
    elapsedTotal = 0,
    keysPressed = 0
  }

  local displayScore = 0
  local m, board, level, comboCounter, lastMatches, lastSelectedCount, start

  function self.setGame(newGame)
    self.elapsedLevel = 0
    self.levelMatches = 0
    m, board, level = newGame.addMessage, newGame.board, newGame.level
    comboCounter, lastMatches, lastSelectedCount = 0, 0, board.selectedCount()
    if lastSelectedCount > 0 then m(lastSelectedCount .. " selected gems left.") end
  end

  function self.slowDropBonus() self.score = self.score + 1 end
  function self.quickDropBonus() self.score = self.score + K.BOARD_HEIGHT end
  function self.keyPress() self.keysPressed = self.keysPressed + 1 end

  function self.resume()
    start = os.time()
  end

  function self.pause()
    if start then
      local elapsed = (os.time() - start)
      self.elapsedLevel = self.elapsedLevel + elapsed
      self.elapsedTotal = self.elapsedTotal + elapsed
      start = nil
    end
  end

  function self.update(dt)
    if displayScore < self.score then
      sounds.sfx("score")
      displayScore = displayScore + dt * 250
      if displayScore > self.score then displayScore = self.score end
    end
  end

  function self.findMatches()
    local d = {sum=0, directions=0, streaks=0}

    local function check(direction, title)
      if not level[direction] then return end

      local matches, streaks = board.findMatches(direction, level[direction])

      if matches and matches > 0 then
        if matches > level[direction] then
          m("Long "..title.." Match!", true)
          self.longMatches = self.longMatches + 1
        end
        self.matches = self.matches + matches
        self.levelMatches = self.levelMatches + matches

        self.score = self.score + matches * 13

        d.directions = d.directions + 1
        d[direction] = { m=matches, s=streaks }
        if streaks > 0 then d.streaks = d.streaks + streaks end
      end
    end

    check("vert", "Vertical")
    check("horz", "Horizontal")
    check("upDiag", "Up Diagonal")
    check("downDiag", "Down Diagonal")

    if d.vert then m(d.vert.m  .. " Vertical!") end
    if d.horz then m(d.horz.m  .. " Horizontal!") end

    if d.upDiag or d.downDiag then
      m(((d.upDiag and d.upDiag.m) or 0) + ((d.downDiag and d.downDiag.m) or 0) .. " Diagonal!")
    end

    if d.directions > 0 or d.streaks > 0 then
      comboCounter = comboCounter + d.streaks
      if comboCounter > 1 then m("COMBO " .. comboCounter .. "X !!!", true) end
      if comboCounter > 2 then chunky.setMode("stripes"); sounds.sfx("shock") end

      self.score = self.score + comboCounter * 13 * 3

      local v, h, ud, dd = d.vert, d.horz, d.upDiag, d.downDiag

      -- fun fun fun! displays an specific message for each kind of match.
      if d.directions > 1 then
        self.multiple = self.multiple + d.directions
        self.score = self.score + d.directions * 13 * 2

        --  if (not v) and (    h) and (not ud) and (not dd) then
            if (not v) and (    h) and (not ud) and (    dd) then m("Horizontal + Diagonal!", true)
        elseif (not v) and (    h) and (    ud) and (not dd) then m("Horizontal + Diagonal!", true)
        elseif (not v) and (    h) and (    ud) and (    dd) then m("Horizontal + Cross!", true)
        --  if (not v) and (not h) and (not ud) and (not dd) then
        --  if (not v) and (not h) and (not ud) and (    dd) then
        --  if (not v) and (not h) and (    ud) and (not dd) then
        elseif (not v) and (not h) and (    ud) and (    dd) then m("Cross!", true)
        elseif (    v) and (    h) and (not ud) and (not dd) then m("Cross!", true)
        elseif (    v) and (    h) and (not ud) and (    dd) then m("Cross + Diagonal!", true)
        elseif (    v) and (    h) and (    ud) and (not dd) then m("Cross + Diagonal!", true)
        elseif (    v) and (    h) and (    ud) and (    dd) then m("Double Cross!", true)
        --  if (    v) and (not h) and (not ud) and (not dd) then
        elseif (    v) and (not h) and (not ud) and (    dd) then m("Diagonal + Vertical!", true)
        elseif (    v) and (not h) and (    ud) and (not dd) then m("Vertical + Diagonal!", true)
        elseif (    v) and (not h) and (    ud) and (    dd) then m("Cross + Vertical!", true)
        end
      end
    end

    local selectedCount = board.selectedCount()

    if selectedcount ~= lastselectedcount then
      lastselectedcount = selectedcount
      if selectedcount == 0 then m("no selected gems left!") else m(selectedcount .. " selected gems left.") end
    end

    if self.levelMatches ~= lastMatches then
      lastMatches = self.levelMatches
      m(lastMatches .. " total gems matched.")
    end
  end

  function self.resetComboCount()
    if comboCounter > 0 then
      self.combos[comboCounter] = (self.combos[comboCounter] or 0) + 1 -- histogram.
    end
    comboCounter = 0
  end

  function self.render(x, y)
    if displayScore > 0 then
      local font, score = K.LCD_FONT, tostring(math.ceil(displayScore))
      local w = font:getWidth(score)
      LG.setFont(font)
      LG.setBlendMode("alpha")
      LG.setColor(255, 255, 255)
      LG.print(score, x - w, y)
    end
  end

  local function timeString(time)
    if not time then return "00:00" end
    local mins, secs = tostring(math.floor(time / 60)), tostring(time % 60)
    while #secs < 2 do secs = "0" .. secs end
    while #mins < 2 do mins = "0" .. mins end
    return  mins..":"..secs
  end

  function self.stats()
    local stats = {}

    stats[#stats + 1] = {"title", "Level Stats"}
    stats[#stats + 1] = {"data", "Level Play Time", timeString(self.elapsedLevel) }
    stats[#stats + 1] = {"data", "Level Matches", self.levelMatches }

    local kps = math.ceil(self.keysPressed / self.elapsedTotal * 100) / 100
    stats[#stats + 1] = {}
    stats[#stats + 1] = {"title", "Cumulative Stats"}
    stats[#stats + 1] = {"data", "Total Play Time", timeString(self.elapsedTotal)}
    stats[#stats + 1] = {"data", "Keys Pressed",  self.keysPressed .. " (" .. kps .. " K.P.S.)" }

    stats[#stats + 1] = {}
    stats[#stats + 1] = {"data", "Total Matches", self.matches}

    local combos = {}
    for i, v in pairs(self.combos) do
      if i == comboCounter then v = v + 1 end
      if v > 0 then
        if i == 1 then
          combos[#combos + 1] = {i, "   * Normal", v}
        else
          combos[#combos + 1] = {i, "   * Combo".. i.."X", v}
        end
      end
    end

    table.sort(combos, function(a, b) return a[1] < b[1] end)
    for i, v in ipairs(combos) do
      if i > 6 then break end
      stats[#stats+1] = {"data", v[2], v[3]}
    end

    if self.multiple > 0 then stats[#stats + 1] = {"data", "   * Simultaneous", self.multiple} end
    if self.longMatches > 0 then stats[#stats + 1] = {"data", "   * Long Matches", self.longMatches} end

    stats[#stats + 1] = {}
    stats[#stats + 1] = {"data", "TOTAL SCORE", self.score }

    return stats
  end

  function self.renderStats(x, y)
    local def, bold = K.DEFAULT_FONT, K.DEFAULT_FONT_BOLD
    local offx, offy = bold:getWidth("A very long title:  "), K.DEFAULT_FONT:getHeight(" ")

    for i, row in ipairs(self.stats()) do
      local kind = row[1]
      if kind == "title" then
        LG.setFont(bold); LG.setColor(255, 255, 255, 255); LG.print(row[2], x, y + (i-1) * offy)
      elseif kind == "data" then
        LG.setFont(def); LG.setColor(255, 212, 212, 255); LG.print(" " .. row[2], x, y + (i-1) * offy)
        LG.setFont(bold); LG.setColor(232, 232, 232, 252); LG.print(" " .. row[3], x + offx, y + (i-1) * offy)
      else
        -- Do nothing.
      end
    end
  end

  return self
end

return scoreKeeper
