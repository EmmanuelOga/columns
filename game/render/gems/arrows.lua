local K = require("game.constants")
local LG = love.graphics
local PI = math.pi

local pairs, ipairs = pairs, ipairs
local match = string.match

local hsl = require("utils.hsl")
local tweener = require("tweener.base")
local easing = require("tweener.easing")

local unit = 16
local arrow = { {8, 7, 10, 7, 10, 9, 8, 9}, {10, 6, 12, 8, 10, 10} }

local tweens = tweener("loopforward") do
  tweens.add(0.8, { offset = unit / 4 }, easing.outBounce)
  tweens.add(0.1, { offset = unit / 7 }, easing.outQuad)
end

local function render(x, y, kind, high, colIdx)
  if high then scale = 4 else scale = 1.5 end
  if not type(colIdx) == "number" or not colIdx or colIdx < 1 or colIdx > K.NUM_GEMS then colIdx = 1 end
  local color = K.GEM_HSL_COLORS[colIdx]

  local polis, offset = {}, nil

  offset = tweens.getCurrentProperties().offset

  -- displace by offset and save in the polis table
  for _, current in ipairs(arrow) do
    poly = {}
    for i, v in ipairs(current) do
      if i % 2 == 0 then poly[i] = v else poly[i] = v + offset end -- only translate x coordinate
    end
    polis[#polis + 1] = poly
  end

  LG.push()
  LG.setLine(3, "smooth")
  LG.translate(x + (K.GEM_SIZE * (1 - scale) / 2), y + (K.GEM_SIZE * (1 - scale) / 2))
  LG.scale(K.GEM_SIZE / unit * scale, K.GEM_SIZE / unit * scale)

  local function doArrow(draw)
    if draw then
      LG.setBlendMode("subtractive")
      LG.setColor(255, 255, 255, 255); for _, poly in ipairs(polis) do LG.polygon("line", poly) end
      LG.setBlendMode("additive")
      if high then LG.setColor(hsl(color[1], color[2], color[3])) else LG.setColor(255, 255, 255, 255) end
      for _, poly in ipairs(polis) do LG.polygon("fill", poly) end
    end

    LG.translate(unit / 2, unit / 2)
    LG.rotate(PI / 4)
    LG.translate(-unit / 2, -unit / 2)
  end

  for _, direction in pairs{ "r", "4", "d", "3", "l", "1", "u", "2" } do
    doArrow(match(kind, direction))
  end

  LG.setBlendMode("alpha")
  LG.pop()
end

return {
  update = function(dt) tweens.update(dt) end,
  render = render
}
