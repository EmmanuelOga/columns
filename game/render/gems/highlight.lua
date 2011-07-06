local K  = require("game.constants")
local LG = love.graphics

local glitter = require("game.render.gems.glitter")
local gemTweens = require("game.render.gems.tweens")
local gemScale = require("game.render.gems.scale")

local hsl = require("utils.hsl")
local rotateAround = require("utils.love").rotateAround

local unit = 16
local function highlight(x, y, index, forcedScale)
  if not index or index > K.NUM_GEMS or index < 1 then index = 1 end
  local tweens, color = gemTweens.gems[index], K.GEM_HSL_COLORS[index]
  local ta = tweens.glitter.get()

  LG.push()

  if forcedScale then
    gemScale(ta.scale * forcedScale, x, y)
  else
    gemScale(ta.scale, x, y)
  end

  rotateAround(unit / 2, unit / 2, ta.angle)

  LG.setBlendMode("alpha")
  glitter(hsl(color[1], color[2], color[3]))

  LG.pop()
end

return highlight
