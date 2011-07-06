local K = require("game.constants")
local LG = love.graphics

local loveUtils = require('utils.love')
local screenLoader = require('utils.screenLoader')
local menus = require('game.menus')
local chunky = require('game.render.chunky')
local bt = require('game.render.bursts')
local rboard = require('game.render.gems.board')

local function soundMenu(returnTo)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  self.onEnter = function()
    chunky.setMode('interference')
    self.selectItem(selection or 1); self.setMousePosition()
  end

  local modes = {} do
    for i, mode in ipairs(love.graphics.getModes()) do
      modes[#modes + 1] = {label = ( mode.width .. "x" .. mode.height ), data=mode, selected=(SCREEN_WIDTH==mode.width and SCREEN_HEIGHT==mode.height)}
    end
  end

  local resolution = self.add(modes)
  local window = self.add{{label="Fullscreen", data="fullscreen", selected=SCREEN_FULLSCREEN}, {label="Windowed", data="windowed", selected=(not SCREEN_FULLSCREEN)}}
  local vsync = self.add{{label="Enable Vertical Sync", selected=SCREEN_VSYNC, data=true}, {label="Disable Vertical Sync", selected=SCREEN_VSYNC, data=false}}

  local fsaa = {} do
    for i = 0, 3 do
      local val = i * 2
      fsaa[#fsaa + 1] = {label=val.." FSAA Buffers", data=val, selected=(SCREEN_FSAA == val)}
    end
  end

  local fsaa = self.add(fsaa)

  self.add("Apply!", function(mode)
    if love.graphics.setMode(resolution.data.width, resolution.data.height, window.data == "fullscreen", vsync.data, fsaa.data) then
      SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_FULLSCREEN, SCREEN_VSYNC, SCREEN_FSAA = resolution.data.width, resolution.data.height, window.data == "fullscreen", vsync.data, fsaa.data
      K.update()
      K.restore() -- overwrite the defaults of update with the stored settings.
      chunky.initialize()
      bt.initialize()
      rboard.createSheet()
      screenLoader.store()
    end
  end)

  self.add("Back", function() return returnTo end)

  function self.draw()
    LG.setFont(K.MENUS_FONT)
    LG.setColor(0, 255, 0, 255)
    loveUtils.printCenter("Options > Screen", K.MENUS_X0)

    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  return self
end

return soundMenu
