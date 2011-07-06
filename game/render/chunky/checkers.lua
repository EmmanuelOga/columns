local K = require("game.constants")

local hsl = require("utils.hsl")
local easing = require('tweener.easing')

local dynArray = require("utils.dynArray")
local timing = require("utils.timing")
local buffer = require('utils.buffer')

local r = math.random
local eh, es, el = easing.outQuad, easing.outExpo, easing.inQuad

local function chunkyCheckers(chunky)
  local self = {}
  local W, H = chunky.w, chunky.h

  local matrix, buf = buffer(W, H), buffer(W, H)

  local size = math.floor(math.min(W, H) / 8) + 1

  local c, d, k, p = 0, 0, 1, 1
  local function render()
    for i, j in chunky.coords() do
      d = matrix[i][j]
      chunky.put(i, j, eh(d, c, 0.5, 1), es(j, 1, -0.5, H), el(j, 0.2, -0.2, H))
    end
  end

  local function checkers()
    p = p - 1
    matrix.clear(0)
    for y = p + 1, H, 2 do
      k = 1 - k
      for x = p + 1, W, 4 do
        matrix.put(1, k * 2 + x, y, 2, 2)
      end
    end
    k = 1 - k
  end

  checkers()
  local timer = timing.interval(5, checkers)

  local function update(dt)
    timer(dt)
    c = c + dt / 20
    render()
  end

  return update
end

return chunkyCheckers
