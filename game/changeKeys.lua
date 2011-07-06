local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')
local sounds = require('game.sounds')

local function mainMenu(returnTo)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  self.onEnter = function()
    chunky.setMode('checkers')
  end

  local index = 1
  local keys = {
    { "LEFT"  , "Moving Left" },
    { "RIGHT" , "Moving Right" },
    { "DOWN"  , "Droping Slow" },
    { "DROP"  , "Droping Fast" },
    { "RUP"   , "Rotating Up" },
    { "RDOWN" , "Rotating Down" },
  }

  function self.draw()
    LG.setFont(K.MENUS_FONT)
    LG.setColor(255, 0, 0, 255)
    local d = K.MENUS_FONT:getHeight("X") / 2
    local y = K.MENUS_X0
    loveUtils.printCenter("Press a Key for", y - d)
    loveUtils.printCenter(keys[index][2], y + d)
  end

  function self.keypressed(key)
    sounds.sfx("menu")
    K.KEYS_SINGLE[keys[index][1]] = key
    index = index + 1
    if index > #keys then return returnTo end
  end

  return self
end

return mainMenu
