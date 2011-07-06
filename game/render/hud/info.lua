local K = require("game.constants")
local LG = love.graphics

local hsl = require("utils.hsl")
local tweener = require('tweener.base')
local easing = require('tweener.easing')

local renderWindow = require('game.render.window')

local hiSecs, hiTime = 4, 0.1 -- highlight time, tilt time
local tweenLight = tweener('forward') do
  for i = 1, (hiSecs / 2) / hiTime do
    tweenLight.add(hiTime, { light = 1.0 })
    tweenLight.add(hiTime, { light = 0.5 })
  end
end

-- render the last K.NUM_MESSAGES messages
local function renderInfo(messages, coords)
  local n
  local s = K.DEFAULT_FONT:getHeight(" ")

  renderWindow.render("Info", coords, function(w, h)
    if #messages > K.NUM_MESSAGES then n = K.NUM_MESSAGES else n = #messages end
    for i = 1, n do
      if i == 1 then
        LG.setColor(hsl(0.3, 1, tweenLight.getCurrentProperties().light))
      else
        LG.setColor(hsl(0.3, 1, i / (i - 1) / K.NUM_MESSAGES / i * 4))
      end

      LG.print(messages[n - i + 1], 10, s * (0.5 + (i - 1)))
    end
  end)
end

return {
  render = renderInfo,
  update = function(dt) tweenLight.update(dt) end,
  colorReset = function() tweenLight.setCurrent(1) end
}
