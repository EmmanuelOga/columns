local LG = love.graphics
local hsl = require("utils.hsl")
local pairs, ipairs = pairs, ipairs

local polysGem = {
-- borders
  {0.6, 0.40, {0, 2, 1.5, 3, 1.5, 13, 0, 14}},
  {0.8, 0.60, {2, 0, 14, 0, 13, 1.5, 3, 1.5}},
  {0.8, 0.60, {16, 2, 16, 14, 14.5, 13, 14.5, 3}},
  {0.6, 0.40, {3, 14.5, 13, 14.5, 14, 16, 2, 16}},

-- corners
  {0.65, 0.15, {2, 0, 3, 1.5, 1.5, 3, 0, 2}},
  {0.95, 0.30, {14, 0, 16, 2, 14.5, 3, 13, 1.5}},
  {0.65, 0.30, {14.5, 13, 16, 14, 14, 16, 13, 14.5}},
  {0.55, 0.15, {1.5, 13, 3, 14.5, 2, 16, 0, 14}},

-- pannels
  {0.5, 0.95, {1.5, 3, 6, 6, 6, 10, 1.5, 13}},
  {0.9, 0.95, {3, 1.5, 13, 1.5, 10, 6, 6, 6}},
  {0.9, 0.95, {10, 6, 14.5, 3, 14.5, 13, 10, 10}},
  {0.5, 0.95, {6, 10, 10, 10, 13, 14.5, 3, 14.5}},

-- big triangles
  {0.60, 0.95, {3, 1.5, 6, 6, 1.5, 3}},
  {1.00, 0.95, {13, 1.5, 14.5, 3, 10, 6}},
  {0.60, 0.95, {10, 10, 14.5,  13, 13, 14.5}},
  {0.45, 0.95, {6, 10, 1.5, 13, 3, 14.5}},

-- center
  {0.75, 1, {6, 6, 10, 6, 10, 10, 6, 10}},
}

local function gemPoly(color, brightness)
  brightness = brightness or 1

  for i, current in ipairs(polysGem) do
    light, alpha, poly = current[1], current[2], current[3]
    LG.setColor(hsl(color[1], color[2], color[3] * light * brightness, alpha))
    LG.polygon("fill", poly)
  end
end

return gemPoly
