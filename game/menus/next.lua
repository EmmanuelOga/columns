local K = require("game.constants")
local LG = love.graphics
local LF = love.filesystem
local menus = require('game.menus')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')
local levelLoader = require('game.levelLoader')

local function mainMenu(game)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)
  local theEnd = not levelLoader(nil, game.level.number + 1)

  self.onEnter = function()
    chunky.setMode('interference')
    LF.write("mlr.dat", game.level.number + 1)
  end

  if theEnd then
    self.add("The End!", function()
      return require("game.intros.credits")(require('game.menus.main')())
    end)
  else
    self.add("Play Next Level!", function()
      return require("game.single")(game.level.number + 1, game.scores)
    end)
  end

  local CONGRATS = {
    "Well Done!",
    "Awesome!",
    "Nice!",
    "Very Good!",
  }

  local congrat = CONGRATS[math.random(#CONGRATS)]

  function self.draw()
    game.scores.renderStats(K.MENUS_X0, SCREEN_HEIGHT / 20)

    LG.setFont(K.MENUS_FONT)
    LG.setColor(0, 255, 0, 255)
    if theEnd then
      loveUtils.printCenter("You Completed COLUMNS!", K.MENUS_Y0 * 1.5)
    else
      loveUtils.printCenter(congrat, K.MENUS_Y0 * 1.5)
    end

    LG.setBlendMode("alpha")
    self.render(K.MENUS_X0, K.MENUS_Y0 * 1.8)
  end

  return self
end

return mainMenu

