local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')

local function optionsMenu(game)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  self.onEnter = function()
    chunky.setMode('fire')
  end

  self.title("")
  self.title("")
  self.title("Final Score: "..game.scores.score)
  self.title("")

  self.add("Back to Menu", function()
    return require('game.menus.main')()
  end)

  print(game.level.number)

  if game.level.number == "endless" then
    self.add("Play Again", function() return require('game.single')("endless") end)
  else
    self.add("Replay Level", function() return require('game.single')(game.level.number) end)
  end

  function self.draw()
    LG.setBlendMode("alpha")

    LG.setFont(K.TITLE_FONT)
    LG.setColor(255, 0, 0, 255)
    local d = K.TITLE_FONT:getHeight("X") / 3
    local y = K.MENUS_X0
    loveUtils.printCenter("GAME", y - d)
    loveUtils.printCenter("OVER", y + d)

    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  return self
end

return optionsMenu
