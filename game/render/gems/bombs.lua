local LG = love.graphics
local match = string.match

local K  = require("game.constants")
local dynArray = require("utils.dynArray")
local arrows = require("game.render.gems.arrows")

local bombs = dynArray()
local bcolor = dynArray()

local function renderBombs(board, x0, y0)
  for x, y, b in board.allCoordinates() do bombs[x][y] = "" end

  local function mark(u, v, kind, color)
    print(color)
    bombs[u][v] = bombs[u][v] .. kind
    bcolor[u][v] = color or 1
  end

  for x, y, b in board.allCoordinates() do
    if b.destroy and b.bomb then
      local kind = b.bomb

      if match(kind, "u") then for i = 1, y       do mark(x, i, "u", b.color) end end
      if match(kind, "d") then for i = y, board.h do mark(x, i, "d", b.color) end end
      if match(kind, "l") then for i = 1, x       do mark(i, y, "l", b.color) end end
      if match(kind, "r") then for i = x, board.w do mark(i, y, "r", b.color) end end

      local function diag(offx, offy, current)
        local i, j = x, y
        while i > 0 and j > 0 and i <= board.w and j <= board.h do
          mark(i, j, current, b.color)
          i = i + offx ; j = j + offy
        end
      end

      if match(kind, "1") then diag(-1, -1, "1") end
      if match(kind, "2") then diag( 1, -1, "2") end
      if match(kind, "3") then diag(-1,  1, "3") end
      if match(kind, "4") then diag( 1,  1, "4") end
    end
  end


  local a
  for bx, by in board.allCoordinates() do
    a = bombs[bx][by]
    if type(a) == "string" and a ~= "" then
      local x, y = x0 + (bx - 1) * K.GEM_SIZE, y0 + (by - 1) * K.GEM_SIZE
      arrows.render(x, y, a, true, bcolor[bx][by])
    end
  end

  return c
end

return renderBombs
