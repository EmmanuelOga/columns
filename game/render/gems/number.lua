local K = require('game.constants')
local LG = love.graphics

local function number(i, j, num)
  local font = K.SMALL_FONT
  local w, h = font:getWidth(" "), font:getHeight(" ")
  local x, y = i + K.GEM_SIZE / 2 - w / 2 - 1, j + K.GEM_SIZE / 2 - h / 2

  LG.setFont(font)
  LG.setBlendMode("subtractive")
  LG.setColor(255, 255, 255, 255)
  LG.print(num, x, y)
end

return number
