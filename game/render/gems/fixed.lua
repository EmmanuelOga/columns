local LG = love.graphics
local K = require("game.constants")
local hsl = require("utils.hsl")
local pairs, ipairs = pairs, ipairs

-- one unit == width of bounding box of the gem as described by the coordinates below.
local unit = 16
local polysGem = {
-- borders
  {0.6, 0.50, {0, 2, 1.5, 3, 1.5, 13, 0, 14}},
  {0.8, 0.70, {2, 0, 14, 0, 13, 1.5, 3, 1.5}},
  {0.8, 0.70, {16, 2, 16, 14, 14.5, 13, 14.5, 3}},
  {0.6, 0.50, {3, 14.5, 13, 14.5, 14, 16, 2, 16}},

-- corners
  {0.65, 1.00, {2, 0, 3, 1.5, 1.5, 3, 0, 2}},
  {0.95, 1.00, {14, 0, 16, 2, 14.5, 3, 13, 1.5}},
  {0.65, 1.00, {14.5, 13, 16, 14, 14, 16, 13, 14.5}},
  {0.65, 1.00, {1.5, 13, 3, 14.5, 2, 16, 0, 14}},

-- pannels
  {0.1, 0.95, {1.5, 3, 3, 1.5, 6, 6, 10, 10, 14.5, 13, 13, 14.5, 3, 14.5, 1.5, 13, 1.5, 3}},
  {0.3, 0.95, {3, 1.5, 13, 1.5, 14.5, 3, 14.5, 13, 10, 10, 6, 6}},
}

local function render(x, y)
  local s = 1
  LG.push()
  LG.translate(x + (K.GEM_SIZE * (1 - s) / 2), y + (K.GEM_SIZE * (1 - s) / 2))
  LG.scale(K.GEM_SIZE / unit * s, K.GEM_SIZE / unit * s)
  LG.setBlendMode("alpha")

  for i, current in ipairs(polysGem) do
    light, alpha, poly = current[1], current[2], current[3]
    LG.setColor(hsl(0, 0, 0.5 * light, alpha))
    LG.polygon("fill", poly)
  end

  LG.setColor(128, 128, 128, 64)
  LG.circle("fill", 4, 4, 2, 6)
  LG.circle("fill", 4, 12, 2, 6)
  LG.circle("fill", 12, 4, 2, 6)
  LG.circle("fill", 12, 12, 2, 6)

  LG.setColor(128, 128, 128, 128)
  LG.circle("fill", 4, 4, 1, 6)
  LG.circle("fill", 4, 12, 1, 6)
  LG.circle("fill", 12, 4, 1, 6)
  LG.circle("fill", 12, 12, 1, 6)

  LG.pop()
end

return {
  render = render
}
