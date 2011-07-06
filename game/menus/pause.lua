local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')

local function pauseMenu(game)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  self.onEnter = function()
    chunky.setMode('drops')
  end

  self.add("Options", function() return require("game.menus.options")(self) end)
  self.add("Restart this Level", function() return require('game.single')(game.level.number) end)
  self.add("Exit to Menu", function() return require('game.menus.main')() end)
  self.add("Return to Game", function() return game end)

  function self.draw()
    game.scores.renderStats(K.MENUS_X0, SCREEN_HEIGHT / 20)
    self.render(K.MENUS_X0, K.MENUS_Y0 * 1.5)
  end

  return self
end

return pauseMenu
