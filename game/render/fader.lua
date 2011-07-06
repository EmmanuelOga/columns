local K = require("game.constants")
local LG = love.graphics

local tweener = require('tweener.base')
local easing = require('tweener.easing')

local function fader(int, stayt, outt)
  local self = {}

  local tweens = tweener("forward") do
    tweens.add({alpha=0})
    tweens.add({alpha=255}, int)
    tweens.add({alpha=255}, stayt)
    tweens.add({alpha=0}, outt)
  end

  self.update = tweens.update

  local color = {}
  self.setColor = function(r, g, b)
    color[1], color[2], color[3], color[4] = r, g, b, tweens.get().alpha
    LG.setColor(color)
  end

  self.finished = tweens.finished

  return self
end

return fader
