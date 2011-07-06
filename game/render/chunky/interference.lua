local K = require("game.constants")

local easing = require('tweener.easing')

local hsl = require("utils.hsl")
local dynArray = require("utils.dynArray")
local buffer = require('utils.buffer')

local timing = require("utils.timing")

local function chunkyInterference(chunky)
  local self = {}
  local W, H = chunky.w, chunky.h

  local matrix, buf = buffer(W, H), buffer(W, H)

  local q = 0
  local function circle(x0, y0, c)
    for i = 1, W / 2 * math.pi, 0.01 do
      matrix.put(c,
        math.floor(x0 + math.sin(i + q) * i),
        math.floor(y0 + math.cos(i + q) * i))
    end
  end

  local c = 0
  local timer = timing.interval(1 / 10, function()
    circle(0, 0, 1)
    circle(W, H, 0.25)
    matrix, buf = matrix.smoothTo(buf)

    for i, j in chunky.coords() do
      d = matrix[i][j]
      chunky.put(i, j, c, 1, easing.inExpo(d, 0, 1, 1))
    end
  end)

  local function update(dt)
    q = q - dt * 2
    c = c + dt / 10
    timer(dt)
  end

  return update
end

return chunkyInterference
