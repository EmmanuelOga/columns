local easing = require("tweener.easing")

local pairs, ipairs, tostring = pairs, ipairs, tostring

-- Valid anim modes, associated with true values for easy validation of
-- params.
local animModes = {
  forward      = true,
  backward     = true,
  loopforward  = true,
  loopbackward = true,
  pingpong     = true,
}

local tweenMeta = {
  __tostring = function(self)
    local str = "tween{"
    for k, v in pairs(self.p) do
      str = str .. " " .. tostring(k) .. "=" .. tostring(v)
    end
    str = str .. " }"
    return str
  end,
}

-- d: duration
-- f: easing function
-- p: properties
local function tween(d, f, p)
  return setmetatable({
    d = d or 1,
    f = f or easing.inExpo,
    p = p or {}
  }, tweenMeta)
end

local function tweener(mode)
  local tweens, currentIndex, elapsed, pingPongDirection

  -- internal function to find a tween in the array of tweens
  local function tweenIndex(tween)
    local pos
    if type(tween) == "table" then
      for i, v in ipairs(tweens) do if v == tween then pos = i; break end end
    elseif type(tween) == "number" then
      pos = tween
    end
    if pos and pos > 0 and pos <= #tweens then return pos end
  end

  -- add a tween
  local function add(...)
    local d, f, p
    local params = {...} -- all this hassle so we can get the fun, table and duration in any order.
    for i = 1, 3 do
      if type(params[i]) == "number" then d = params[i]
      elseif type(params[i]) == "table" then p = params[i]
      elseif type(params[i]) == "function" then f = params[i]
      end
    end
    local t = tween(d, f, p) -- ok, from this on actually do useful stuff :).
    tweens[#tweens + 1] = t
    if not currentIndex then currentIndex = 1 end
    return t
  end

  -- tween can be an actual tween returned by add or a number.
  local function remove(tween)
    local pos = tweenIndex(tween)
    if pos then
      local t = table.remove(tweens, pos)
      if #tweens > currentIndex then currentIndex = #tweens end
      return t
    end
  end

  -- set current tween.
  -- tween can be an actual tween returned by add or a number.
  local function setCurrent(tween)
    local pos = tweenIndex(tween)
    if pos then
      currentIndex = pos
      elapsed = 0
    end
  end

  -- returns the current tween an its index
  local function getCurrent()
    return tweens[currentIndex], currentIndex
  end

  local function getNext()
    if #tweens <= 1 then
      return tweens[currentIndex], currentIndex
    else
      if mode == "forward" then
        local nextIndex = currentIndex + 1
        return tweens[nextIndex], nextIndex

      elseif mode == "backward" then
        local nextIndex = currentIndex - 1
        return tweens[nextIndex], nextIndex

      elseif mode == "loopforward" then
        local nextIndex = currentIndex + 1
        if nextIndex > #tweens then nextIndex = 1 end
        return tweens[nextIndex], nextIndex

      elseif mode == "loopbackward" then
        local nextIndex = currentIndex - 1
        if nextIndex < 1 then nextIndex = #tweens end
        return tweens[nextIndex], nextIndex

      elseif mode == "pingpong" then
        local nextIndex = currentIndex + pingPongDirection
        if nextIndex > #tweens then
          nextIndex = #tweens - 1
        elseif nextIndex < 1 then
          nextIndex = 2
        end
        return tweens[nextIndex], nextIndex
      end
    end
  end

  -- mode: forward, backward, loopforward, loopbackward, pingpong
  -- defaults to "forward".
  local function setMode(newMode)
    newMode = newMode or "forward"
    assert(animModes[newMode], tostring(newMode) .. " is invalid, must be one of the valid animation modes")
    mode = newMode
  end

  local function moveToNextIndex()
    if #tweens <= 1 then
      currentIndex = #tweens
    else
      if mode == "forward" then
        if currentIndex < #tweens then currentIndex = currentIndex + 1 end

      elseif mode == "backward" then
        if currentIndex > 1 then currentIndex = currentIndex - 1 end

      elseif mode == "loopforward" then
        if currentIndex < #tweens then currentIndex = currentIndex + 1 else currentIndex = 1 end

      elseif mode == "loopbackward" then
        if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = #tweens end

      elseif mode == "pingpong" then
        currentIndex = currentIndex + pingPongDirection
        if currentIndex > #tweens then
          pingPongDirection, currentIndex = -1, #tweens - 1
        elseif currentIndex <= 1 then
          if #tweens > 2 then pingPongDirection, currentIndex = 1, 1 else pingPongDirection, currentIndex = -1, 2 end
        end
      end
    end
  end

  -- returns current mode
  -- make things move!
  -- dt: number of seconds elapsed.
  -- note: if the number of senconds elapsed is greater than the current
  -- tween duration, it will just skip to the next tween, i.e. it won't
  -- jump tweens.
  local function update(dt)
    elapsed = elapsed + dt

    local currentTween, nextTween = getCurrent(), getNext()

    if #tweens > 1 then
      if nextTween and (elapsed >= nextTween.d) then
        moveToNextIndex()
        elapsed = 0
      end
    else
      elapsed = 0
    end

    return #tweens == currentIndex
  end

  -- returns a new table with the current properties
  -- (depending on the elapsed time they can be interpolated or not)
  local function getCurrentProperties()
    local p = {}
    local currentTween = getCurrent()
    local nextTween = getNext()

    if currentTween then
      for k, v in pairs(currentTween.p) do p[k] = v end
    end

    if nextTween and elapsed > 0 then
      local b
      local duration = nextTween.d
      local fun = nextTween.f
      for k, e in pairs(nextTween.p) do
        b = p[k]
        if type(b) == "number" and type(e) == "number" then -- the property exists in the current Tween and is interpolable.
          -- Minimal paramters needed for all easing functions, for reference.
          -- t = time     should go from 0 to duration
          -- b = begin    value of the property being ease.
          -- c = change   ending value of the property - beginning value of the property
          -- d = duration
          p[k] = fun(elapsed, b, e - b, duration)
        end
      end
    end

    return p
  end

  local function reset()
    tweens = {}        -- Initial tween.
    currentIndex = nil -- current tween index
    elapsed = 0        -- elapsed time.
    pingPongDirection = 1
  end

  reset()
  setMode(mode)

  return {
    getCurrentProperties = getCurrentProperties,
    get = getCurrentProperties,
    add = add,
    remove = remove,
    reset = reset,
    restart = function() setCurrent(1) end,
    getLength = function() return #tweens end,
    getElapsed = function() return elapsed end,
    finished = function() return #tweens == currentIndex end,
    setCurrent = setCurrent,
    getCurrent = getCurrent,
    getNext = getNext,
    setMode = setMode,
    getMode = function () return mode end,
    update = update,
    eachTween = function() local i = 0; return function() i = i + 1; if i <= #tweens then return i, tweens[i] end end end,
  }
end

return tweener
