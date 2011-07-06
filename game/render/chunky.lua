local K = require("game.constants")
local LG = love.graphics

local hsl = require("utils.hsl")
local buffer = require('utils.buffer')

-- draw scenes using 'chunky pixels'
local function chunkyInit()
  local S = math.sqrt(math.min(SCREEN_WIDTH, SCREEN_HEIGHT)) * K.BACKGROUND_CELL_SIZE
  local W, H = math.floor(SCREEN_WIDTH / S) + 1, math.floor(SCREEN_HEIGHT / S) + 1

  local self = buffer(W, H)

  self.clear({0, 0, 0}) -- initial h,s,l for each point.

  local c
  function self.render()
    LG.setBlendMode("alpha")

    for i, j in self.coords() do
      c = self[i][j]
      LG.setColor(hsl(c[1], c[2], c[3]))
      LG.rectangle("fill", (i - 1) * S, (j - 1) * S, S, S)
    end
  end

  local bufferPut = self.put
  function self.put(x, y, h, s, l, ww, hh)
    bufferPut({h or 0, s or 1, l or 0.5}, x, y, ww, hh)
  end

  local bufferClear = self.clear
  function self.clear(h, s, l)
    bufferClear({h or 0, s or 1, l or 0.5})
  end

  return self
end

local self = {} -- singleton.

self.modes = {"checkers", "drops", "fire", "interference", "stripes"}
self.randomModes = {"checkers", "drops", "fire", "interference"}

self.randomMode = function()
  local options = {}
  for _, mode in ipairs(self.randomModes) do if self.mode ~= mode then options[#options+1] = mode end end
  return options[math.random(#options)]
end

-- set a random state different to the current one.
self.randomize = function()
  self.setMode(self.randomMode())
end

self.initialize = function()
  self.render = function()end
  self.update = function()end
  if K.BACKGROUND_CELL_SIZE ~= 0 then
    self.chunky = chunkyInit()
    self.render = self.chunky.render
    self.setMode(self.mode)
  end
end

self.setMode = function(mode)
  if mode == self.mode then return end
  self.mode = mode
  if K.BACKGROUND_CELL_SIZE ~= 0 and mode then
    self.render = self.chunky.render
    self.update = require('game.render.chunky.' .. mode)(self.chunky)
  else
    self.render = function()end
    self.update = function()end
  end
end

self.initialize()

return self
