local K = require("game.constants")

local function countDown(speed)
  local self = {speed = speed or 1}

  self.reset = function()
    self.current = K.TIMER.MAX_TIME
  end

  self.update = function(dt)
    self.current = self.current - (self.speed or 1) * dt
    if self.current < 0 then
      self.reset()
      if self.callback then self.callback() end
    end
  end

  self.reset()

  return self
end

return countDown
