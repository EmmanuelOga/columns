--[[
      ____ ___  _    _   _ __  __ _   _ ____  _
     / ___/ _ \| |  | | | |  \/  | \ | / ___|| |
    | |  | | | | |  | | | | |\/| |  \| \___ \| |
    | |__| |_| | |__| |_| | |  | | |\  |___) |_|
     \____\___/|_____\___/|_|  |_|_| \_|____/(_)

            a Game made in Buenos Aires

Made by Emmanuel Oga (http://emmanueloga.com), powered by löve (http://love2d.org)

Please inspect the CREDITS file for information about the game assets.
Please inspect the LICENSE file for license information.

]]--

require 'coreExt'
--require 'utils.tracer'

local LG = love.graphics
local transition = require("utils.transition")
local konami = require('game.konami')
local gemTweens = require("game.render.gems.tweens")
local delay = require('game.delay')
local rthunder = require('game.render.thunder')

local K, state, sounds, chunky

COLUMNS_VERSION = "0.0.1"

function love.load()
  K = require("game.constants") -- defines constants and initializes some stuff
  K.restore() -- try to restore previous user settings.

  chunky = require('game.render.chunky')
  sounds = require("game.sounds")

  -- delay: windows takes some time to stabilize the window.
  state = transition(state, delay(2, require('game.intros.love')()))
  chunky.setMode("interference")
end

-- all love callbacks get delegated to the current state.
-- any callback can change the state to the next one.
for _, callbackName in ipairs{"mousepressed"} do -- ha! there used to be more stuff in this table.
  love[callbackName] = function(...)
    local callback = state[callbackName]
    if callback then state = transition(state, callback(...)) end
  end
end

-- specialized callbacks which do other things appart from the stuff that
-- happens in the current state
function love.keypressed(key, unicode)
  if konami(key) then state = transition(state, require('game.intros.konami')(state)) end
  if key == "n" then rthunder.trigger() end
  if state.keypressed then state = transition(state, state.keypressed(key, unicode)) end
end

function love.update(dt)
  sounds.update(dt)
  chunky.update(dt)
  gemTweens.update(dt)
  if state.update then state = transition(state, state.update(dt)) end
end

function love.draw()
  -- background is drawn in all states. If it is disabled draw a solid color.
  if K.BACKGROUND_CELL_SIZE ~= 0 then chunky.render() else
    LG.setBlendMode("alpha")
    LG.setColor(0, 32, 0)
    LG.rectangle('fill', 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
  end

  if state.draw then state = transition(state, state.draw()) end

  if K.SHOW_FPS then
    LG.setFont(K.DEFAULT_FONT)
    LG.setBlendMode("alpha")
    LG.setColor(255, 255, 255)
    LG.print(love.timer.getFPS() .. " FPS", 0, 0)
  end
end
