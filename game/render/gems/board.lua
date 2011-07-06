-- Create a sprite sheet and render gems.
local K = require("game.constants")
local LG = love.graphics
local GT = require("game.render.globalTweens")

local tweener = require("tweener.base")
local easing = require("tweener.easing")

local bgem      = require('game.render.gems.bgem')
local fixed     = require("game.render.gems.fixed")
local gemPoly   = require("game.render.gems.poly")
local gemScale  = require("game.render.gems.scale")
local gemTweens = require("game.render.gems.tweens")
local obstacle  = require("game.render.gems.obstacle")
local rbombs    = require("game.render.gems.bombs")

local sheet, batch, quads

local blink = tweener('loopforward') do
  blink.add({now=true}, 1/30)
  blink.add({now=false}, 1/30)
end

-- creates the gems sprite sheet, the sprite batch object and the quads.
local function createSheet()
  local x, y
  local sheetSize = 2 ^ math.ceil(math.log2(math.max(K.GEM_SIZE * 10, K.GEM_SIZE * (K.NUM_GEMS + 1))))
  print("Rendering spritesheet of size: " .. sheetSize)

  sheet, quads = LG.newFramebuffer(sheetSize, sheetSize), {}

  sheet:renderTo(function()
    for i, color in ipairs(K.GEM_HSL_COLORS) do
      local quadsColor = {}
      for b = 1, 10 do
        LG.push()
        x, y = (b - 1) * K.GEM_SIZE, (i - 1) * K.GEM_SIZE
        gemScale(1, x, y)
        gemPoly(color, 1 + 0.5 * (b / 10))
        LG.pop()
        quadsColor[#quadsColor+1] = LG.newQuad(x, y, K.GEM_SIZE, K.GEM_SIZE, sheetSize, sheetSize)
      end
      quads[#quads + 1] = quadsColor
    end

    x, y = 0, K.NUM_GEMS * K.GEM_SIZE
    obstacle.render(x, y)
    quads.obstacle = LG.newQuad(x, y, K.GEM_SIZE, K.GEM_SIZE, sheetSize, sheetSize)

    x, y = K.GEM_SIZE, K.NUM_GEMS * K.GEM_SIZE
    fixed.render(x, y)
    quads.fixed = LG.newQuad(x, y, K.GEM_SIZE, K.GEM_SIZE, sheetSize, sheetSize)
  end)

  batch = LG.newSpriteBatch(LG.newImage(sheet:getImageData()), K.BOARD_WIDTH * K.BOARD_HEIGHT)
  sheet = nil
end

createSheet()

local function addGem(gem, x0, y0, bx, by)
  local quad
  local x, y = x0 + (bx - 1) * K.GEM_SIZE, y0 + (by - 1) * K.GEM_SIZE -- screen position
  local l = gemTweens.gems[gem.color or K.NUM_GEMS].lightIndex()

  if     gem.hole     then quad = nil
  elseif gem.normal   then quad = quads[gem.color][l]
  elseif gem.wild     then quad = quads[gemTweens.wild.get().gem.color][l]
  elseif gem.obstacle then quad = quads.obstacle
  elseif gem.fixed    then quad = quads.fixed
  end

  if quad then batch:addq(quad, x, y) end
end

local function renderBoard(board, column, x0, y0)
  batch:clear()

  -- board
  for i, j, gem in board.allCoordinates(K.HIDDEN_LINES + 1) do -- start from non hidden lines.
    addGem(gem, x0, y0, i, j - K.HIDDEN_LINES)
  end

  -- column
  local fits, colGems = column.fits(), {}
  if fits or blink.get().now then
    local offset

    if column.board.isFree(column.x, column.y + column.h) then
      offset = y0 + easing.linear(1 - column.left, 0, K.GEM_SIZE, 1)
    else
      offset = y0
    end

    for i, j, b in column.allCoordinates() do
      addGem(b, x0, offset, i, j - K.HIDDEN_LINES)
      colGems[#colGems+1] = {b, x0, offset, i, j - K.HIDDEN_LINES, true}
    end

    LG.setBlendMode("alpha")
    LG.setLine(2, "smooth")
    LG.setLineStipple(GT.stipple())

    if not fits then
      LG.setColor(GT.red(), 0, 0, 255)
    else
      LG.setColor(128, 128, 128, 255)
    end

    LG.rectangle("line", (column.x-1) * K.GEM_SIZE + x0,
                         (column.y-1) * K.GEM_SIZE + offset, K.GEM_SIZE, K.COLUMN_HEIGHT * K.GEM_SIZE)
    LG.setLineStipple(0xffff)
  end

  LG.setBlendMode("alpha")
  LG.setColor(255, 255, 255, 242)
  LG.draw(batch)

  -- now draw the board "artifacts"
  for i, j, gem in board.allCoordinates(K.HIDDEN_LINES + 1) do -- start from non hidden lines.
    bgem(gem, x0, y0, i, j - K.HIDDEN_LINES, true)
  end

  for _, params in pairs(colGems) do bgem(unpack(params)) end

  rbombs(board, x0, y0)
end

return {
  update = blink.update,
  createSheet = createSheet,
  render = renderBoard
}
