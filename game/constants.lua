require 'coreExt'

local K = {}
local LG = love.graphics
local loader = require 'utils.loader'

-- only some keys are storables, namely the ones that are not user data or
-- affected by the screen height and width.
local STORABLES = {
  "KEYS_SINGLE", "SFX_VOLUME", "BGM_VOLUME", "MASTER_VOLUME",
  "PARTICLES_ENABLED", "SHAKE_ENABLED", "THUNDER_ENABLED", "SHOW_NEXT", "SHOW_STATS", "SHOW_INFO",
  "SHOW_FPS", "BACKGROUND_CELL_SIZE"
}

K.store = function()
  local settings = {}
  for _, v in ipairs(STORABLES) do settings[v] = K[v] end
  loader.saveTable("settings.dat", settings)
  print("Saved settings.")
end

K.restore = function()
  local settings = loader.loadTable('settings.dat')

  if not settings then
    print("Could not load non-screen user settings.")
  else
    for _, v in ipairs(STORABLES) do
      if type(settings[v]) ~= "nil" then K[v] = settings[v] end
    end
    print("Restored previous non-screen settings.")
  end

  -- only this one needs to be applied right away.
  love.audio.setVolume(K.MASTER_VOLUME)
end

-- calculates the current constants
-- (some of them change with the screen height and width)
K.update = function()
  local w, h = SCREEN_WIDTH, SCREEN_HEIGHT

  -- one color for each of our gems
  K.GEM_HSL_COLORS = {
    {60 + 360 / 6 * 0, 1.0, 0.55 },
    {60 + 360 / 6 * 1, 1.0, 0.50 },
    {60 + 360 / 6 * 2, 1.0, 0.50 },
    {60 + 360 / 6 * 3, 1.0, 0.55 },
    {60 + 360 / 6 * 4, 1.0, 0.50 },
    {60 + 360 / 6 * 5, 1.0, 0.50 },
  }

  K.NUM_GEMS = #K.GEM_HSL_COLORS

  -- clamp gem colors into 0..1 values.
  for _, color in ipairs(K.GEM_HSL_COLORS) do color[1] = (color[1] % 360) / 360 end

  -- board logical size
  K.BOARD_WIDTH = 9
  K.BOARD_HEIGHT = 21
  K.HIDDEN_LINES = 0
  K.COLUMN_HEIGHT = 3
  K.VISIBLE_BOARD_HEIGHT = K.BOARD_HEIGHT - K.HIDDEN_LINES
  K.BOARD_SHAKE_OFFSET = w / 50 -- set to 0 to disable

  K.COLUMN_FALL_SPEED = 0.75 -- how many seconds to wait until push down.
  K.COLUMN_LAY_TIME = 0.7 -- how many seconds to wait until placement

  K.SHAKE_ENABLED = true
  K.PARTICLES_ENABLED = true
  K.SHOW_FPS = false
  K.BACKGROUND_CELL_SIZE = 2 -- 0.5 to 10
  K.THUNDER_ENABLED = true

  -- playfields sizes
  K.WIDTH_BORDER = w / 30
  K.PFW = w - 2 * K.WIDTH_BORDER -- playfield width
  K.PFH = K.PFW / math.phi       -- playfield height, golden ratio.
  K.HEIGHT_BORDER = ( h - K.PFH ) / 2

  -- board and gems sizes. Gems are always square
  K.GEM_SIZE = math.ceil(h * 0.98 / K.VISIBLE_BOARD_HEIGHT)
  K.BOARD_SCREEN_WIDTH = K.GEM_SIZE * K.BOARD_WIDTH
  K.BOARD_SCREEN_HEIGHT = K.GEM_SIZE * K.VISIBLE_BOARD_HEIGHT

  K.NORMAL_GEM_SCALE = 1     -- shrink a little the gems so there is space between them.
  K.GLITTER_LIGHT_STRENGTH = 128 -- alpha of the "glitter" of gems.

  K.NUM_MESSAGES = 7

  ----------------------------------------------------------------------------

  local winOffset = K.HEIGHT_BORDER / 3

  K.SINGLE = {  -- placement of stuff for single player mode.
    SCORE = {
      x = SCREEN_WIDTH - math.min(w, h) / 16,
      y = 0,
    }
  }

  K.SINGLE.NEXT = {
    x = K.WIDTH_BORDER + K.PFW - (7 / math.phi * K.GEM_SIZE),
    y = K.SINGLE.SCORE.y + K.HEIGHT_BORDER + math.min(w, h) / 16,
    w = 7 / math.phi * K.GEM_SIZE,
    h = 7 * K.GEM_SIZE,
  }

  K.SINGLE.STATS = {
    x = K.WIDTH_BORDER + K.PFW - (7 / math.phi * K.GEM_SIZE),
    y = K.SINGLE.NEXT.y + K.SINGLE.NEXT.h + winOffset,
    w = 7 / math.phi * K.GEM_SIZE,
    h = 7 * K.GEM_SIZE,
  }

  K.SINGLE.TIMER = {
    x = K.WIDTH_BORDER,
    y = K.HEIGHT_BORDER,
    w = ( K.PFW - K.PFH ),
    h = ( K.PFW - K.PFH ) / math.phi * 3 / 5 ,
  }

  K.SINGLE.LEVEL = {
    x = K.WIDTH_BORDER,
    y = K.SINGLE.TIMER.y + K.SINGLE.TIMER.h + winOffset,
    w = K.PFW - K.PFH,
    h = ( K.PFW - K.PFH ) / math.phi
  }

  K.SINGLE.INFO = {
    x = K.WIDTH_BORDER,
    y = K.SINGLE.LEVEL.y + K.SINGLE.LEVEL.h + winOffset,
    w = K.PFW - K.PFH,
    h = ( K.PFW - K.PFH ) / math.phi
  }

  K.SINGLE.LEVEL_NO_TIMER = { x = K.WIDTH_BORDER, y = K.SINGLE.TIMER.y, w = K.SINGLE.LEVEL.w, h = K.SINGLE.LEVEL.h }
  K.SINGLE.INFO_NO_TIMER = { x = K.WIDTH_BORDER, y = K.SINGLE.LEVEL_NO_TIMER.y + K.SINGLE.LEVEL_NO_TIMER.h + winOffset, w=K.SINGLE.INFO.w, h=K.SINGLE.INFO.h }

  K.SINGLE.BOARD = {
    x = ( K.SINGLE.LEVEL.x + K.SINGLE.LEVEL.w + K.SINGLE.NEXT.x - K.BOARD_SCREEN_WIDTH ) / 2,
    y = ( SCREEN_HEIGHT - K.BOARD_SCREEN_HEIGHT ) / 2,
    w = K.BOARD_SCREEN_WIDTH,
    h = K.BOARD_SCREEN_HEIGHT,
  }

  K.TIMER = { SEGMENTS = {7, 6, 4}, MAX_TIME = 110 }
  K.TIMER.TOTAL_SEGEMENTS = K.TIMER.SEGMENTS[1] + K.TIMER.SEGMENTS[2] + K.TIMER.SEGMENTS[3]

  K.PARTICLES_BASE_SIZE = 2 ^ math.ceil(math.log2(K.GEM_SIZE * 3))
  K.PARTICLES_INTENSITY = 0.75
  K.PARTICLES_EMISSION_TIME = 0.001
  K.PARTICLE_BUFFER_PER_CEL = 100

  K.BASE_DESTROY_TIME = 1
  K.NORMAL_DESTROY_TIME = 0.1
  K.BURN_DESTROY_TIME = 0.05

  -- fonts
  K.TITLE_FONT   = LG.newFont('media/fonts/virgo.ttf', math.min(w, h) / 4)
  K.SCORE_FONT   = LG.newFont('media/fonts/virgo.ttf', math.min(w, h) / 8)
  K.LCD_FONT     = LG.newFont('media/fonts/virgo.ttf', math.min(w, h) / 16)
  K.SMALL_FONT   = LG.newFont('media/fonts/virgo.ttf', math.min(w, h) / 36)

  K.MENUS_FONT   = LG.newFont('media/fonts/slkscrb.ttf', math.min(w, h) / 16)

  K.OSD_FONT     = LG.newFont('media/fonts/slkscr.ttf', math.min(w, h) / 8)
  K.DEFAULT_FONT = LG.newFont('media/fonts/slkscr.ttf', math.min(w, h) / 35)
  K.DEFAULT_MED  = LG.newFont('media/fonts/slkscr.ttf', math.min(w, h) / 32)

  K.DEFAULT_FONT_BOLD = LG.newFont('media/fonts/slkscreb.ttf', math.min(w, h) / 35)

  K.INTRO_FONT   = LG.newFont('media/fonts/nevis.ttf', math.min(w, h) / 16)
  K.CREDITS_FONT = LG.newFont('media/fonts/nevis.ttf', math.min(w, h) / 16)

  K.TITLE_X0 = (w - K.TITLE_FONT:getWidth("COLUMNS!")) / 2
  K.TITLE_Y0 = (0 + K.TITLE_FONT:getHeight("X") / 6)

  K.TITLE_SHADOW_X0 = K.TITLE_X0 + K.TITLE_FONT:getWidth("X") / 15
  K.TITLE_SHADOW_Y0 = K.TITLE_Y0 + K.TITLE_FONT:getHeight("X") / 20

  K.MENUS_X0 = K.TITLE_X0 + math.min(w, h) / 8
  K.MENUS_Y0 = h - K.MENUS_FONT:getHeight("COLUMNS!") * 1.1 * 8.5
  K.MAX_MENU_ITEMS = 7

  K.MENU_SELECTED_OFFSET = math.min(w, h) / 32
  K.MENU_UNSELECTED_FG = {255, 255, 255, 212}
  K.MENU_SELECTED_FG_HSL = {0, 1, 0.6}

  K.SHOW_INFO = true
  K.SHOW_STATS = false
  K.SHOW_NEXT = true

  K.MASTER_VOLUME = 1
  K.SFX_VOLUME = 0.4
  K.BGM_VOLUME = 0.15

  love.audio.setVolume(K.MASTER_VOLUME)

  K.KEYS_SINGLE = {
    RUP    = "up",
    DOWN   = "down",
    LEFT  = "left",
    RIGHT = "right",
    DROP  = " ",
    RDOWN  = "control",
  }

  -- if called multiple times this method can generate quite some garbage.
  collectgarbage("collect")

  return K
end

return K.update()
