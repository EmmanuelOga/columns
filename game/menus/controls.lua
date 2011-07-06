local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')
local changeKeys = require('game.changeKeys')

local function mainMenu(returnTo)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  self.add("Change Keys", function() return changeKeys(self) end)
  self.add("Back", function() return returnTo end)

  self.onEnter = function()
    chunky.setMode('drops')
    self.selectItem(selection or 1); self.setMousePosition()
  end

  self.draw = function()
    LG.setFont(K.MENUS_FONT)
    LG.setColor(0, 255, 0, 255)
    loveUtils.printCenter("Options > Controls", K.MENUS_X0)

    LG.setBlendMode("alpha")
    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  return self
end

return mainMenu
