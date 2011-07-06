local LG = love.graphics
local K = require("game.constants")

local unit = 16
local function gemScale(s, x, y)
  LG.translate(x + (K.GEM_SIZE * (1 - s) / 2), y + (K.GEM_SIZE * (1 - s) / 2))
  LG.scale(K.GEM_SIZE / unit * s, K.GEM_SIZE / unit * s)
end

return gemScale
