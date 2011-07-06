local LG = love.graphics
local K = require('game.constants')

local tweener = require('tweener.base')
local easing = require('tweener.easing')

local sounds = require('game.sounds')

-- just a fade to white right now.
local thunder = tweener("forward") do
  thunder.add({bright = 0})
  thunder.add({bright = 255}, 0.05, easing.outElastic)
  thunder.add({bright = 0}, 0.25, easing.linear)
  thunder.setCurrent(3)
end

local function render()
  if K.THUNDER_ENABLED then
    local b = thunder.getCurrentProperties().bright

    if b > 0 then
      LG.setBlendMode("additive")

      if b > 212 then
        LG.setColor(255, 255, 255, (128 + math.random(b - 127) / 10) / 1.5)
      else
        LG.setColor(255, 255, 255, b / 1.5)
      end

      LG.rectangle("fill", 0, 0, LG.getWidth(), LG.getHeight())
    end
  end
end

return {
  render = render,
  trigger = function(volume) thunder.setCurrent(1); sounds.sfx("thunder", 1, volume or 1) end,
  update = function(dt) thunder.update(dt) end,
}
