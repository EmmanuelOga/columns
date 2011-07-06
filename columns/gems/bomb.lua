local match = string.match

local function processBomb(board, x, y)
  local kind = board.get(x, y).bomb

  if not kind then return end

  local sequence = 0
  local c = 0 -- count of matches
  local function mark(u, v, currrent)
    local b = board.get(u, v)
    if b and (b.wild or b.normal) then
      sequence = sequence + 0.1
      c = c + 1
      b.matched = true
      b.arrowMatched = ( b.arrowMatched or "" ) .. currrent -- mark arrow matches everywhere
      b.arrowSequence = sequence
    end
  end

  if match(kind, "u") then for i = 1, y - 1       do mark(x, i, "u") end end
  if match(kind, "d") then for i = y + 1, board.h do mark(x, i, "d") end end
  if match(kind, "l") then for i = 1, x - 1       do mark(i, y, "l") end end
  if match(kind, "r") then for i = x + 1, board.w do mark(i, y, "r") end end

  local function diag(offx, offy, current)
    local i = x + offx ; local j = y + offy
    while i > 0 and j > 0 and i <= board.w and j <= board.h do
      mark(i, j, current)
      i = i + offx ; j = j + offy
    end
  end

  if match(kind, "1") then diag(-1, -1, "1") end
  if match(kind, "2") then diag( 1, -1, "2") end
  if match(kind, "3") then diag(-1,  1, "3") end
  if match(kind, "4") then diag( 1,  1, "4") end

  return c
end

return processBomb
