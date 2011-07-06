local K  = require("game.constants")
local LG = love.graphics
local random = math.random

local arrows    = require("game.render.gems.arrows")
local burn      = require('game.render.gems.burn').render
local fixed     = require("game.render.gems.fixed").render
local highlight = require("game.render.gems.highlight")
local number    = require("game.render.gems.number")
local obstacle  = require("game.render.gems.obstacle").render
local rgem      = require('game.render.gems.gem').render
local selected  = require("game.render.gems.selected")

local function render(gem, x0, y0, bx, by, bypassGem)
  local x, y = x0 + (bx - 1) * K.GEM_SIZE, y0 + (by - 1) * K.GEM_SIZE

  if not bypassGem then -- only draw the actual gem if requested, otherwise only draw gem accessories
    if     gem.hole     then -- do nothing
    elseif gem.fixed    then fixed(x, y)
    elseif gem.obstacle then obstacle(x, y)
    elseif gem.normal   then rgem(x, y, gem.color)
    elseif gem.wild     then rgem(x, y, "wild")
    end
  end

  if gem.burn then burn(x, y) end

  if not gem.destroy and (gem.normal or gem.wild) and gem.bomb then arrows.render(x, y, gem.bomb, false) end

  if gem.color and gem.stays and gem.stays > 1 then number(x, y, gem.stays - 1) end

  if     gem.destroy  then highlight(x, y, (gem.wild and random(K.NUM_GEMS)) or gem.color)
  elseif gem.selected then selected(x, y)
  end
end

return render
