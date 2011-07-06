local K = require("game.constants")
local LG = love.graphics

local renderWindow = require('game.render.window')
local renderBoardGems = require('game.render.gems.bgem')

local function renderNext(nextColumn, coords)
  renderWindow.render("Next!", coords, function(w, h)
    local scale = h / ( K.GEM_SIZE * 3.25 )
    local x, y = ( w / scale - K.GEM_SIZE ) / 2, ( h / scale - K.GEM_SIZE * 3 ) / 2

    LG.push()
    LG.scale(scale, scale)

    for i, j, b in nextColumn.allCoordinates() do
      renderBoardGems(b, x, y, 1, j)
    end

    LG.pop()
  end)
end

return renderNext
