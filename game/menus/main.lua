local K = require("game.constants")
local LG = love.graphics
local menus = require('game.menus')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')
local sounds = require('game.sounds')

local tweener = require('tweener.base')
local easing = require('tweener.easing')

local function mainMenu()
  local self = menus(K.MENUS_X0, K.MENUS_Y0, 1.1)

  local title, selection

  self.onEnter = function()
    chunky.setMode('interference')
    title = tweener("forward") do
      title.add({x=K.TITLE_X0, y=-SCREEN_HEIGHT / 3, sx=K.TITLE_SHADOW_X0, sy=K.TITLE_SHADOW_Y0 * 2})
      title.add({x=K.TITLE_X0, y=K.TITLE_Y0, sx=K.TITLE_SHADOW_X0, sy=K.TITLE_SHADOW_Y0}, easing.outBounce)
    end
    sounds.sfx("shock", 5, 0.1);
    self.selectItem(selection or 1); self.setMousePosition()
  end

  self.onExit = function() selection = self.currentSelection() end

  self.add("Choose Level",  function() return require("game.menus.levels")() end)
  self.add("Endless Mode", function() return require("game.single")("endless") end)
  self.add("Options",      function() return require("game.menus.options")(self) end)
  self.add("Credits",      function() return require("game.intros.credits")(self) end)
  self.add("Exit",         function() love.event.push('q') end)

  local p
  function self.draw()
    p = title.get()
    LG.setFont(K.TITLE_FONT)
    LG.setBlendMode("alpha")
    LG.setColor(0, 0, 0, 128); LG.print("COLUMNS!", p.sx, p.sy)

    LG.setBlendMode("additive")
    LG.setColor(255, 255, 255, 212); LG.print("COLUMNS!", p.x, p.y)

    LG.setBlendMode("alpha")
    self.render(K.MENUS_X0, K.MENUS_Y0)
  end

  local update = self.update
  self.update = function(dt)
    title.update(dt)
    update(dt)
  end

  return self
end

return mainMenu
