local screenLoader = require('utils.screenLoader')

function love.conf(t)
  t.identity = "lovely-columns" -- The name of the save directory (string)
  love.filesystem.setIdentity(t.identity)
  screenLoader.restore()

  t.screen.width      = SCREEN_WIDTH
  t.screen.height     = SCREEN_HEIGHT
  t.screen.fullscreen = SCREEN_FULLSCREEN
  t.screen.vsync      = SCREEN_VSYNC
  t.screen.fsaa       = SCREEN_FSAA

  t.modules.joystick = false  -- Enable the joystick module (boolean)
  t.modules.physics = false   -- Enable the physics module (boolean)

  t.modules.mouse = true      -- Enable the mouse module (boolean)
  t.modules.audio = true      -- Enable the audio module (boolean)
  t.modules.event = true      -- Enable the event module (boolean)
  t.modules.image = true      -- Enable the image module (boolean)
  t.modules.timer = true      -- Enable the timer module (boolean)
  t.modules.sound = true      -- Enable the sound module (boolean)
  t.modules.keyboard = true   -- Enable the keyboard module (boolean)
  t.modules.graphics = true   -- Enable the graphics module (boolean)

  t.title = "Columns"
  t.author = "Emmanuel Oga"
  t.version = 0.7             -- The LÖVE version this game was made for (number)
end
