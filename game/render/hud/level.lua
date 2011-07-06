local K = require("game.constants")
local LG = love.graphics

local renderWindow = require('game.render.window')

local function renderLevel(level, coords)
  renderWindow.render(level.name, coords, function(w, h)
    local s = K.DEFAULT_MED:getHeight(" ")
    LG.setColor(0, 255,0)
    LG.setFont(K.DEFAULT_MED)
    LG.printf(level.message, w / 40, s * 0.5, w - w / 20)
  end)
end

return renderLevel
