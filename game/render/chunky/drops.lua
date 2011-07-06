local K = require("game.constants")

local hsl = require("utils.hsl")
local easing = require('tweener.easing')

local dynArray = require("utils.dynArray")
local timing = require("utils.timing")
local buffer = require('utils.buffer')

local r = math.random
local eh, es, el = easing.linear, easing.linear, easing.outExpo

local function chunkyDrops(chunky)
  local W, H = chunky.w, chunky.h

  local drops, buf = buffer(W, H), buffer(W, H)

  local clear = 1
  local size = math.floor(math.min(W, H) / 10) + 1

  local timers = {
    timing.interval(1,      function(dt) drops.put(r(), r(W), r(H), size, size) end),
    timing.interval(1 / 5,  function(dt) drops, buf = drops.smoothTo(buf) end),
    timing.interval(1 / 10, function(dt) drops.multiply(clear) end),
    timing.interval(2 / 1,  function(dt) clear = clear * 0.99; if clear < 0.9 then clear = 1 end end),
  }

  local c, d = 0, 0
  local function render()
    for i, j in chunky.coords() do
      d = drops[i][j]
      chunky.put(i, j, eh(d, c, 0.25, 1), es(j, 1, -0.5, H), el(d, 0, 0.75, 1))
    end
  end

  local function update(dt)
    for _, timer in ipairs(timers) do timer(dt) end
    c = c + dt / 10
    render()
  end

  return update
end

return chunkyDrops
