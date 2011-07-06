local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')

local sound = require('game.sounds')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')

local function soundMenu(returnTo)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  local lastSong = sound.whatsPlaying()
  self.onExit = function()
    if lastSong then sound.bgm(lastSong) else sound.stopBgm() end
  end

  local bgms = {}
  for song, _ in pairs(sound.bgms) do
    bgms[#bgms + 1] = {label="BGM: "..song, data=song, selected=lastSong==song}
  end
  self.add(bgms, function(song) sound.bgm(song) end)

  local sounds = {}
  for sfx, _ in pairs(sound.sfxs) do
    sounds[#sounds + 1] = {label="SFX: "..sfx, data=sfx, selected=lastSong==song}
  end
  self.add(sounds, function(sfx) sound.sfx(sfx) end)

  local modes = {}
  for _, v in ipairs(chunky.modes) do
    modes[#modes + 1] = {label=v, data=v, selected=chunky.mode == v}
  end

  self.add(modes, function(mode) chunky.setMode(mode) end)

  self.add("Back to Game!", function() return returnTo end)

  function self.draw()
    LG.setFont(K.MENUS_FONT)
    LG.setColor(255, 255, 0, 255)
    loveUtils.printCenter("BG and BGM Test Screen", K.MENUS_X0)

    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  return self
end

return soundMenu
