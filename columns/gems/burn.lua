local K = require("game.constants")

local function processBurn(board, x, y)
  local burn = board.get(x, y)

  burn.destroy = K.BURN_DESTROY_TIME

  local function destroy(matcher)
    local c = 1
    for u, v, b in board.allCoordinates() do
      if b and not b.destroy and not b.selected and matcher(b) then
        b.matched, b.burnMatched, c = true, true, c + K.BURN_DESTROY_TIME
      end
    end
    return c
  end

  if y < board.h then
    local kindToBurn = board.get(x, y + 1)

    if kindToBurn.wild then
      return destroy(function(b) return b.wild end)

    elseif kindToBurn.obstacle then
     return  destroy(function(b) return b.obstacle end)

    elseif kindToBurn.normal then
      local color = kindToBurn.color
      return destroy(function(b) return b.normal and b.color == color end)
    end
  end

  return 0
end

return processBurn
