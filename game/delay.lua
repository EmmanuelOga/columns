-- this is a simple state that only waits seconds until retuning the next state.
-- On windows it takes some time to stabilize the window after starting love,
-- so I'm using this to be able to show the intro properly.

local LG = love.graphics

local function delay(seconds, state)
  local self = {}

  local count = 0
  function self.update(dt)
    count = count + dt
    if count > seconds then return state end
  end

  return self
end

return delay
