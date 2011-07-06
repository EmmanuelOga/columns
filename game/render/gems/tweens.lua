 -- Tweens used to animate gems colors and 'glitter', etc...

local K = require("game.constants")
local tweener = require("tweener.base")
local easing = require("tweener.easing")
local floor = math.floor

local gemTweens = {} do
  for i = 1, K.NUM_GEMS do
    local tweens = { glitter = tweener("loopforward"), scale = tweener("loopforward"), light = tweener("loopforward") }

    -- selected gem brightness
    tweens.light.add(1.25,  easing.outInCircle, {bright = 1})
    tweens.light.add(0.75, easing.inOutBounce, {bright = 10})
    tweens.light.add(0.50, easing.inOutCircle, {bright = 5})
    for n = 1, (25 / K.NUM_GEMS * i) do tweens.light.update(n / 10) end

    tweens.lightIndex = function() return floor(tweens.light.get().bright + 0.5) end

    -- setup glitter tweens
    tweens.glitter.add(1.25, easing.inOutBounce, { angle = math.pi, scale = 5 })
    tweens.glitter.add(0.5, easing.inOutBounce, { angle = 0, scale = 2.5 })
    for n = 1, (17.5 / K.NUM_GEMS * i) do tweens.glitter.update(n / 10) end

    -- setup glitter scale tween
    tweens.scale.add(0.3, easing.inExpo, {scale = 0.1 })
    tweens.scale.add(0.3, easing.outExpo, {scale = K.NORMAL_GEM_SCALE })
    for n = 1, (6 / K.NUM_GEMS * i) do tweens.scale.update(n / 10) end

    gemTweens[i] = tweens
  end
end

local stippleTweens = tweener('loopforward') do
  stippleTweens.add({ stipple = '0xf0f0' }, 0.25)
  stippleTweens.add({ stipple = '0x0f0f' }, 0.25)
end

local wildTweens = tweener('loopforward') do
  for i = 1, K.NUM_GEMS do wildTweens.add({ gem = {color=i} }, 1/15) end
end

local function update(dt)
  for i, tweens in ipairs(gemTweens) do
    tweens.glitter.update(dt)
    tweens.scale.update(dt)
    tweens.light.update(dt)
  end
  stippleTweens.update(dt)
  wildTweens.update(dt)
end

return {
  gems = gemTweens,
  wild = wildTweens,
  update = update,
  stipple = stippleTweens,
}
