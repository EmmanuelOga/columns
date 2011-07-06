-- returns a function that, invoked with a delta, calls the callback
-- when the total time is reached. if provided, the elseCallback
-- will be invoked on each call with time < total.
local function timeout(total, callback, elseCallback, periodic)
  local elapsed = 0
  return function(dt)
    elapsed = elapsed + dt
    if elapsed >= total then
      callback(total, dt, elapsed, total - elapsed)
      if periodic then elapsed = 0 end
    elseif elseCallback then
      elseCallback(total, dt, elapsed, total - elapsed)
    end
  end
end

-- returns a function that, invoked with a delta, calls the callback
-- when the total time is reached, and then resets the elapsed time.
-- if provided, the elseCallback will be invoked on each call with time < total.
local function interval(total, callback, elseCallback)
  return timeout(total, callback, elseCallback, true)
end

return {
  timeout = timeout,
  interval = interval,
}
