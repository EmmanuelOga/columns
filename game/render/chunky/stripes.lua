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
  local W, H, MAX_STRIPES = chunky.w, chunky.h, chunky.h * 4
  local matrix = buffer(W, H)

  local min, max = W / 4, W
  local function newStripe()
    local l = math.floor(min + (max - min) * math.random())
    return { x = 2 * W - math.random(W) + l, y = math.random(H), l = l, speed=math.random(W/5) }
  end

  local stripes = {} do
    for i = 1, MAX_STRIPES do stripes[#stripes + 1] = newStripe() end
  end

  local function putStripe(x, y, length)
    for i = x, x + length do matrix.put(easing.linear(i - x, 0.5, -0.5, length), i, y) end
  end

  local hue = 0
  local function updateStripes()
    matrix.clear(0)
    for i, s in ipairs(stripes) do
      if s.x + s.l > 1 then
        s.x = s.x - s.speed
      else
        stripes[i] = newStripe()
      end
      putStripe(s.x, s.y, s.l)
    end

    for i, j in chunky.coords() do
      chunky.put(i, j, hue, 1, matrix.get(i, j))
    end
  end

  local t = timing.interval(1/60, updateStripes)

  local function update(dt)
    hue = hue + dt / 10
    t(dt)
  end

  return update
end

return chunkyCheckers
