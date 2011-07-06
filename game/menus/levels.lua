local K = require("game.constants")
local LG = love.graphics
local LF = love.filesystem
local menus = require('game.menus')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')

local levelLoader = require('game.levelLoader')

local function levelMenu()
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  self.onEnter = function()
    chunky.setMode('checkers')
  end

  local maxLevelReached
  if LF.isFile("mlr.dat") then
    mlr = LF.read("mlr.dat"); maxLevelReached = tonumber(mlr)
  else
    maxLevelReached = 1
  end

  for i = 1, 50 do
    if i > maxLevelReached then break end
    local level = levelLoader(nil, i)
    if not level then break end
    self.add(i..". "..level.name, function() return require("game.single")(i) end)
  end

  self.add("Cancel", function() return require("game.menus.main")() end)

  function self.draw()
    LG.setFont(K.DEFAULT_FONT)
    LG.setColor(255, 255, 255, 255)

    LG.setBlendMode("alpha")
    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  return self
end

return levelMenu
