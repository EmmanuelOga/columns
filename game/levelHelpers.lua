local K = require("game.constants")
local gems = require("columns.gems")

local function probability(column, tab)
  local p, kind, callback

  for i = 0, #tab / 3 - 1 do
    p, kind, callback = tab[i*3+1], tab[i*3+2], tab[i*3+3]

    if math.random() > (1 - p) then
      if kind == "any" then
        callback(math.random(K.COLUMN_HEIGHT))
      else
        for k = 1, K.COLUMN_HEIGHT do
          if column[k][kind] then callback(k); break end
        end
      end
      return
    end
  end
end

-- parses a representation of the board initial state and sets it on the board.
local function mapParser(board, map, mappings)
  -- since the maps are represented from bottom to top, it is easier to
  -- push all gems in a row array first and then dump them to the board.
  local rows = {}

  mappings = mappings or {}

  for line in string.gmatch(string.gsub(map, " ", ""), "(%b||)") do
    local row = {}
    line = line.sub(line, 2, #line - 1) -- inner contents.

    -- each step through this loop represents a different gem.
    for _, code in ipairs{string.match(line, string.rep("(.)", board.w))} do
      local num = tonumber(code)

      if num and num > 0 and num <= K.NUM_GEMS then row[#row+1] = gems.normal{color=num}
      elseif code == "f" or code == "F"        then row[#row+1] = gems.fixed()
      elseif code == "o" or code == "O"        then row[#row+1] = gems.obstacle()
      elseif mappings[code] then
        local gemp = mappings[code]
        row[#row+1] = gems[gemp[1]](gemp[2])
      else
        row[#row+1] = gems.hole()
      end
    end

    rows[#rows + 1] = row
  end

  -- now set the board rows.
  for j, row in ipairs(rows) do
    for i, gem in ipairs(row) do
      board.set(i, board.h - #rows + j, gem)
    end
  end
end

return {
  mapParser = mapParser,
  probability = probability
}
