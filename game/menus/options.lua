local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')

local function optionsMenu(returnTo)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)
  local selection

  self.onEnter = function()
    chunky.setMode('drops')
    self.selectItem(selection or 1); self.setMousePosition()
  end

  self.onExit = function()
    K.store() -- this is so cheap, it iss ok to store the current settings even if no default changed.
    selection = self.currentSelection()
  end

  self.add("Screen Mode", function() return require('game.menus.screen')(self) end)
  self.add("Music & SFX", function() return require('game.menus.sound')(self) end)
  self.add("Visuals", function() return require('game.menus.visuals')(self) end)
  self.add("Controls", function() return require('game.menus.controls')(self) end)
  self.add("Back", function() return returnTo end)

  function self.draw()
    LG.setFont(K.MENUS_FONT)
    LG.setColor(0, 255, 0, 255)
    loveUtils.printCenter("Options", K.MENUS_X0)

    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  return self
end

return optionsMenu
