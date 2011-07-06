local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')
local sound = require('game.sounds')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')

local function soundMenu(returnTo)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  self.onEnter = function()
    chunky.setMode('interference')
    self.selectItem(selection or 1); self.setMousePosition()
  end

  local function volumes(label, current)
    local volumes, val = {}
    for i = 1, 21 do
      val = (i - 1) * 5
      local tl
      if val == 0 then tl = label .. " OFF" else tl = label.." "..val.."/100" end
      volumes[#volumes + 1] = {
        data     = val / 100,
        label    = tl,
        selected = (current - val / 100) < ( 1 / 100 )
      }
    end
    return volumes
  end

  local lastSong, lastBGMVolume = sound.whatsPlaying(), K.BGM_VOLUME

  self.add(volumes("Master Volume", K.MASTER_VOLUME), function(vol) K.MASTER_VOLUME = vol; love.audio.setVolume(vol) end)
  self.add(volumes("SFX",           K.SFX_VOLUME),    function(vol) K.SFX_VOLUME = vol end)
  self.add(volumes("Music",         K.BGM_VOLUME),    function(vol)
    lastBGMVolume, K.BGM_VOLUME = K.BGM_VOLUME, vol
    if lastSong and lastBGMVolume <= 0 then sound.bgm(lastSong) end
  end)

  self.add("Back", function() return returnTo end)

  function self.draw()
    LG.setFont(K.MENUS_FONT)
    LG.setColor(0, 255, 0, 255)
    loveUtils.printCenter("Options > Music & SFX", K.MENUS_X0)

    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  return self
end

return soundMenu
