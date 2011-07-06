-- Current and new states are tables which optionally contain functions named
-- after löve callbacks, and two additional function 'onEnter' and 'onExit'.
local function transition(current, new)
  if new then
    if current and current.onExit then current.onExit() end
    if new.onEnter then new.onEnter() end
    return new
  else
    return current
  end
end

return transition
