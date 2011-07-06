local K = require("game.constants")
local LG = love.graphics

local gem = require('game.render.gems.gem').render
local renderWindow = require('game.render.window')

local function renderStats(stats, coords)
  renderWindow.render("Stats", coords, function(w, h)
    LG.setBlendMode("alpha")

    local tx, ty, y
    local scale = (K.NUM_GEMS - 1) * K.GEM_SIZE / h
    local fh = K.DEFAULT_FONT:getHeight(" ") / 2

    for i = 1, K.NUM_GEMS do
      y = (i - 0.95) / (K.NUM_GEMS - 2) * (K.NUM_GEMS - 1) * (K.GEM_SIZE * scale)

      gem(0, y, i, scale)

      if stats and stats[i] and stats[i] > 0 then
        tx, ty = K.GEM_SIZE * scale * 1.25, y + fh
        LG.print(string.format("%.2f", stats[i]) .. '%', tx, ty)
      end
    end
  end)
end

return renderStats
