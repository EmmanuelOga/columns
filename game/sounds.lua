-- plays sounds, xfades music.
local K = require("game.constants")
local LS = love.sound
local random = math.random
local tweener = require('tweener.base')
local easing = require('tweener.easing')

FADING_TIME = 1.25

local function sounds()
  local self, sfxs, bgms = {}, {}, {}

  -- name, path, ..., path
  local function addSfx(...)
    local name, mode = ...
    local args = {select(3, ...)}
    local data = {}; data[mode] = true
    assert(mode=="seq" or mode=="mul", "mode must be 'seq' (sequential) or 'mul' (can be played multiple times)")
    for _, val in ipairs(args) do
      if type(val) == "function" then
        data.callback = val
      else
        data[#data + 1] = LS.newSoundData("media/sounds/" .. val)
      end
    end
    sfxs[name] = data
  end

  local function addBgm(name, path, kind)
    local source, state, elapsed = love.audio.newSource("media/music/" .. path, kind), "stopped", 0

    source:setLooping(true)

    local fader = tweener("forward") do
      fader.add({ fin=0, fout=1 })
      fader.add({ fin=1, fout=0 }, FADING_TIME, easing.linear)
    end

    local function play()
      if state ~= "playing" then
        state="fin"
        source:setVolume(0)
        source:rewind()
        source:play()
        fader.restart()
      end
    end

    local function stop()
      if state ~= "stopped" then
        if not source:isStopped() then
          state="fout"
          fader.restart()
        end
      end
    end

    local function update(dt)
      if K.BGM_VOLUME <= 0 then state = "fout" end
      if state == "fin" or state == "fout" then
        fader.update(dt)
        local v = fader.getCurrentProperties()[state]
        source:setVolume(v * K.BGM_VOLUME)
        if v <= 0 then
          source:stop()
          state = "stopped"
        elseif v >= 1 then
          state = "playing"
        end
      elseif state == "playing" then
        source:setVolume(K.BGM_VOLUME)
      end

      if source:isStopped() then elapsed = 0 else elapsed = elapsed + dt end
    end

    bgms[name] = {
      name    = name,
      source  = source,
      update  = update,
      play    = play,
      stop    = stop,
      state   = function() return state end,
      elapsed = function() return elapsed end
    }
  end

  local function whatsPlaying()
    for name, bgm in pairs(bgms) do
      if bgm.state() == "playing" or bgm.state() == "fin" then return name end
    end
  end

  -- private auxiliar function
  local function play(data, pitch, vol, cbk)
    local source = love.audio.newSource(data)
    source:setPitch(pitch or 1)
    source:setVolume(K.SFX_VOLUME * (vol or 1))
    if cbk then cbk(source, pitch, K.SFX_VOLUME * (vol or 1)) end
    source:play()
    return source
  end

  local function sfx(name, pitch, volume)
    if K.SFX_VOLUME <= 0 then return end
    local data = sfxs[name]
    if not data then print("Warning! missing sfx " .. tostring(name)); return end

    if data.seq then
      if not data.current or data.current:isStopped() then
        data.current = play(data[random(#data)], pitch, volume, data.callback)
      end
    elseif data.mul then
      play(data[random(#data)], pitch, volume, data.callback)
    end
  end

  local function randomSong()
    local songs = {}
    for name, bgm in pairs(bgms) do
      if bgm.state() ~= "playing" and bgm.state() ~= "fin" then songs[#songs + 1] = name end
    end
    if #songs > 0 then
      return songs[math.random(#songs)]
    end
  end

  -- play song or xfade if there is one already playing.
  local function bgm(newName)
    newName = newName or randomSong()
    for name, bgm in pairs(bgms) do
      if newName == name then bgm.play() else bgm.stop() end
    end
  end

  -- fade out song.
  local function stopBgm()
    for _, bgm in pairs(bgms) do bgm.stop() end
  end

  local function update(dt)
    for _, bgm in pairs(bgms) do bgm.update(dt) end

    -- if shuffle is set, check the elapsed time of the current song and switch to next if needed.
    if self.shuffleTime then
      local current = whatsPlaying()
      if current and bgms[current].elapsed() > self.shuffleTime then bgm() end
    end
  end

  self.addSfx = addSfx
  self.addBgm = addBgm
  self.sfx = sfx
  self.bgm = bgm
  self.stopBgm = stopBgm
  self.update = update
  self.bgms = bgms
  self.sfxs = sfxs
  self.whatsPlaying = whatsPlaying
  self.shuffleTime = false -- set to number of seconds to enable automatic shuffling after tine elapsed.

  return self
end

local function randomPitch(attenuation, min, max)
  return function(source, pitch, vol)
    source:setPitch(min + random() * (max - min))
    source:setVolume(vol * attenuation)
  end
end

local s = sounds()

s.shuffleTime = false

s.addSfx("alarm",    "seq", "alarm.ogg")
s.addSfx("nonfit",   "seq", "lock.ogg")
s.addSfx("destroy",  "mul", "crash.ogg")
s.addSfx("score",    "seq", "score.ogg")
s.addSfx("drop",     "mul", "drop.ogg")
s.addSfx("floor",    "mul", "mechanical_door.ogg")
s.addSfx("menu",     "mul", "menu.ogg")
s.addSfx("rotate",   "mul", "rotate.ogg")
s.addSfx("shock",    "mul", "shock.ogg", "teleport.ogg")
s.addSfx("thunder",  "mul", "explosion1.ogg", "explosion2.ogg", "explosion3.ogg", "explosion4.ogg", randomPitch(1, 0.9, 1.1))
s.addSfx("crackers", "seq", "crackers.ogg", "crackers2.ogg", "crackers3.ogg", randomPitch(0.75, 4, 6))

s.addBgm("4u"       , "4u.s3m"                                , "stream")
s.addBgm("morphine" , "morphine.xm"                           , "stream")
s.addBgm("music"    , "music.mod"                             , "stream")
s.addBgm("satell"   , "satell.s3m"                            , "stream")
s.addBgm("economic" , "te-econo.it"                           , "stream")
s.addBgm("trance"   , "trance.s3m"                            , "stream")
s.addBgm("lum"      , "Rushjet1-Luminosity_and_Viscosity.ogg" , "stream")
s.addBgm("classic1" , "v-cf.it"                               , "stream")
s.addBgm("classic2" , "v-cf2.s3m"                             , "stream")

return s
