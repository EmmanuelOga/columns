local K = require("game.constants")
local LG = love.graphics

local renderWindow = require('game.render.window')

local sounds = require('game.sounds')

local hsl = require('utils.hsl')
local tweener = require('tweener.base')
local easing = require('tweener.easing')

local MAX_TIME = 99.99 -- maximum time displayed.

-- this is not really a timer, but a countdown displayer.
-- the difference is that it can take more or less than 100 seconds to reach from 0 to 100.
local function renderTimer(time, coords)
  local critical = (K.TIMER.SEGMENTS[1] - 1) / K.TIMER.TOTAL_SEGEMENTS
  local segments = K.TIMER.SEGMENTS
  local totalSegments = K.TIMER.TOTAL_SEGEMENTS
  local hue, sat, lig

  if not time or time > MAX_TIME then time = MAX_TIME end

  renderWindow.render("Timer", coords, function(w, h)
    LG.setFont(K.LCD_FONT)
    LG.setLine(2, "smooth")

    local a = h / 2
    local b = -a / segments[2]
    local phase, x0, y0, x1, y1, u
    local segW = w / totalSegments
    local offset = segW / 10

    for i = 1, totalSegments do
      if i < segments[1] then phase = 1
      elseif i < segments[1] + segments[2] then phase = 2
      else phase = 3
      end

      if phase == 1 then
        x0, y0, x1, y1 = (i - 1) * segW, a, i * segW, a
      elseif phase == 2 then
        x0, x1 = (i - 1) * segW, i * segW
        u = (i - segments[1])
        y0, y1 = b * u + a, b * (u+1) + a
      else
        x0, y0, x1, y1 = (i - 1) * segW, 0, i * segW, 0
      end

      if i > time / MAX_TIME * totalSegments then
        sat, lig, hue = 0, 0.1, 0
      else
        sat, lig, hue = 1, 0.5, easing.inOutCirc(i, 0, 0.3, totalSegments)
      end

      LG.setColor(0, 0, 0, 196)
      LG.polygon("line", x0 + offset, y0, x0 + offset, h, x1 - offset, h, x1 - offset, y1)
      LG.setColor(hsl(hue, sat, lig))
      LG.polygon("fill", x0 + offset, y0, x0 + offset, h, x1 - offset, h, x1 - offset, y1)
    end

    LG.setColor(255, 255, 255)
    local t = string.format("%.2f", time); while #t < 5 do t = "0" ..t end
    LG.print(t, K.LCD_FONT:getWidth(' ') / 2, 0)
  end, time / MAX_TIME < critical)

  if time / MAX_TIME < critical then sounds.sfx("alarm") end
end

return renderTimer
