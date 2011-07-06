local K = require('game.constants')
local LG = love.graphics
local GT = require("game.render.globalTweens")
local gemTweens = require("game.render.gems.tweens")
local gemScale = require("game.render.gems.scale")

local unit = 16
local function selected(x, y, forcedScale)
  LG.push()
  if forcedScale then scale = forcedScale else scale = K.NORMAL_GEM_SCALE end
  gemScale(scale, x, y)

  LG.setBlendMode("alpha")
  LG.setLineStipple(GT.stipple())
  LG.setColor(255, 255, 255, 212)
  LG.setLine(2, "smooth")
  LG.rectangle("line", 0, 0, unit + 1, unit + 1)
  LG.setLineStipple(0xffff)

  LG.pop()
end

return selected
