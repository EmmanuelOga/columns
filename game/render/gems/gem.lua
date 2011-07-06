-- gem renders only the gem w/o any addons (number, arrows, selection, etc...)
-- bgem uses gem to render the base and then add all those artifacts.
local K = require("game.constants")
local LG = love.graphics

local hsl = require("utils.hsl")
local loveUtils = require("utils.love")
local pairs, ipairs = pairs, ipairs

local gemPoly =  require("game.render.gems.poly")
local gemTweens = require("game.render.gems.tweens")
local gemScale = require("game.render.gems.scale")

-- scale and angle are optional.
local unit = 16 -- TODO move this to the gemPoly file.
local function render(x, y, gemIdx, forcedScale)
  local scale, tweens, color

  if gemIdx == "wild" then
    tweens = gemTweens.gems[K.NUM_GEMS] -- arbitrarily picking the last one.
    color = K.GEM_HSL_COLORS[gemTweens.wild.get().gem.color]
  else
    tweens, color = gemTweens.gems[gemIdx], K.GEM_HSL_COLORS[gemIdx]
  end

  if forcedScale then
    scale = forcedScale
  else
    if highlight then scale = tweens.scale.get().scale else scale = K.NORMAL_GEM_SCALE end
  end

  LG.push()
  gemScale(scale, x, y)
  LG.setBlendMode("alpha")
  gemPoly(color, 1 + 0.5 * (tweens.light.get().bright / 10))
  LG.pop()
end

return {
  render = render,
}
