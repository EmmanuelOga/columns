local K = require("game.constants")
local LG = love.graphics
local random = math.random

local MAX_SHAKE_TIME = 4

-- make the screen shake.
local function quake()
  local self = {quake=0}

  local function randOffset()
    return random(K.BOARD_SHAKE_OFFSET) - K.BOARD_SHAKE_OFFSET / 2
  end

  function self.apply()
    if self.quake > 0 then LG.translate(randOffset(), randOffset()) end
  end

  function self.shake(time)
    if self.quake < MAX_SHAKE_TIME then self.quake = self.quake + time end
  end

  function self.update(dt)
    self.quake = self.quake - dt
    if self.quake < 0 then self.quake = 0 end
  end

  return self
end

return quake
