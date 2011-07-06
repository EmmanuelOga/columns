local K = require("game.constants")
local LG = love.graphics

local hsl = require("utils.hsl")
local tweener = require("tweener.base")
local easing = require("tweener.easing")

local pairs, ipairs = pairs, ipairs

local tweensOff = {tweener("loopforward"), tweener("loopforward"), tweener("loopforward")} do
  for i, t in ipairs(tweensOff) do
    t.add({offset = -K.GEM_SIZE / 2  }, 1, easing.inBack)
    t.add({offset = K.GEM_SIZE / 4  }, 1, easing.outBounce)
    t.update(i * 1 / 3)
  end
end

local function render(x, y)
  LG.push()
  LG.translate(x, y)
  LG.scale(K.GEM_SIZE / K.PARTICLES_BASE_SIZE, K.GEM_SIZE / K.PARTICLES_BASE_SIZE)

  local b = K.PARTICLES_BASE_SIZE / 2

  local offset1 = tweensOff[1].getCurrentProperties().offset
  local offset2 = tweensOff[2].getCurrentProperties().offset
  local offset3 = tweensOff[3].getCurrentProperties().offset

  LG.setBlendMode("additive")

  for i = 1, 4 do
    LG.setColor(hsl(0, 1, i / 16, 0.6))
    LG.circle("fill", b, offset1 + b, i * 16, 20)

    LG.setColor(hsl(0,.3, 1, i / 16, 0.6))
    LG.circle("fill", b, offset2 + b, i * 16, 20)

    LG.setColor(hsl(0.6, 1, i / 16, 0.6))
    LG.circle("fill", b, offset3 + b, i * 16, 20)
  end

  LG.pop()
end

return {
  render = render,
  update = function(dt) for i, t in ipairs(tweensOff) do t.update(dt); end end
}
