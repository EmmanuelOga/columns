local tweener = require('tweener.base')
local easing = require('tweener.easing')

local tPulse = tweener("loopforward") do
  tPulse.add({r = 128}, 0, easing.inSine)
  tPulse.add({r = 255}, 1 / 3, easing.outSine)
end

local tStipple = tweener('loopforward') do
  tStipple.add({ stipple = '0xf00f' }, 0.5)
  tStipple.add({ stipple = '0x0ff0' }, 0.5)
end

return {
  red = function() return tPulse.get().r end,
  stipple = function() return tStipple.get().stipple end,

  update = function(dt)
    tPulse.update(dt)
    tStipple.update(dt)
  end,
}
