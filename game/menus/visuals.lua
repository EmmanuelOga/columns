local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')
local chunky = require('game.render.chunky')
local loveUtils = require('utils.love')

local function soundMenu(returnTo)
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  self.onEnter = function()
    chunky.setMode('interference')
    self.selectItem(selection or 1); self.setMousePosition()
  end

  local function addToggle(Kname, labelTrue, labelFalse)
    self.add({
      {label=labelTrue, data=true, selected=K[Kname]},
      {label=labelFalse, data=false, selected=(not K[Kname])}
    }, function(data) K[Kname] = data end)
  end

  addToggle("PARTICLES_ENABLED", "Particles Enabled"   , "Particles Disabled")
  addToggle("SHAKE_ENABLED"    , "Screen Shake Enabled", "Screen Shake Disabled")
  addToggle("THUNDER_ENABLED"  , "Fade to White Enabled", "Fade to White Disabled")
  addToggle("SHOW_NEXT"        , "Next Column Enabled" , "Next Column Disabled")
  addToggle("SHOW_STATS"       , "Stats Enabled"       , "Stats Disabled")
  addToggle("SHOW_INFO"        , "Info Window Enabled" , "Info Window Disabled")
  addToggle("SHOW_FPS"         , "Show FPS"            , "Hide FPS")

  self.add({
    {label="Background OFF",           data=0,   selected=(K.BACKGROUND_CELL_SIZE == 0)},
    {label="Background L.o.D. FAST",   data=5,   selected=(K.BACKGROUND_CELL_SIZE == 5)},
    {label="Background L.o.D. NORMAL", data=2,   selected=(K.BACKGROUND_CELL_SIZE == 2)},
    {label="Background L.o.D. GOOD",   data=1,   selected=(K.BACKGROUND_CELL_SIZE == 1)},
    {label="Background L.o.D. BEST",   data=0.5, selected=(K.BACKGROUND_CELL_SIZE == 0.5)},
  }, function(data)
    K.BACKGROUND_CELL_SIZE = data
    local prevMode = chunky.mode
    chunky.mode = nil
    chunky.initialize()
    chunky.setMode(prevMode)
  end)

  self.add("Back", function() return returnTo end)

  function self.draw()
    LG.setFont(K.MENUS_FONT)
    LG.setColor(0, 255, 0, 255)
    loveUtils.printCenter("Options > Visuals", K.MENUS_X0)

    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  return self
end

return soundMenu
