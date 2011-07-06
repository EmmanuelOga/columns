-- love logo and intro.
local K = require("game.constants")
local LG = love.graphics
local LU = require('utils.love')

local tweener = require('tweener.base')
local easing = require('tweener.easing')

local sounds = require('game.sounds')
local rthunder = require('game.render.thunder')

local function loveIntro()
  local self = {}

  local img = LG.newImage("media/graphics/love-logo-512x256.png")
  local madeText = 'Made in Buenos Aires, with'

  local lx, ly = (SCREEN_WIDTH - 512) / 2, (SCREEN_HEIGHT - 256) / 2

  local fh =  K.INTRO_FONT:getWidth("X")
  local offx = K.INTRO_FONT:getWidth(madeText)
  local madex = (SCREEN_WIDTH - offx) / 2

  local alpha = tweener("forward") do
    alpha.add({alpha=0})
    alpha.add({alpha=255}, 2, easing.outQuad)
  end

  local made = tweener("forward") do
    made.add({x=-offx,        y=ly - fh})
    made.add({x=madex,        y=ly - fh}, 3, easing.outBack)
    made.add({x=madex,        y=ly - fh}, 2.5)
    made.add({x=SCREEN_WIDTH, y=ly - fh}, 1)

    made.render = function()
      local madep = made.get()
      LG.setColor(0, 0, 255)
      LG.print(madeText, madep.x, madep.y)
    end
  end

  local logo = tweener("forward") do
    logo.add({x=lx, y=0})
    logo.add({x=lx, y=ly}, 3, easing.outBounce)
    logo.add({x=lx, y=ly}, 2.5)
    logo.add({x=lx, y=SCREEN_HEIGHT}, 1, easing.inBack)

    logo.render = function()
      local logop = logo.get()
      LG.setFont(K.INTRO_FONT)
      LG.setColor(255, 255, 255, alpha.get().alpha)
      LG.draw(img, logop.x, logop.y)
    end
  end

  self.onEnter = function() sounds.sfx("shock", 1, 0.25); rthunder.trigger(0.25) end

  function self.draw()
    LG.setBlendMode("alpha")
    logo.render()
    made.render()
    rthunder.render()
  end

  function self.update(dt)
    rthunder.update(dt)
    alpha.update(dt)
    made.update(dt)
    logo.update(dt)
    if logo.finished() then return require('game.menus.main')() end
  end

  function self.keypressed()
    return require('game.menus.main')()
  end

  return self
end

return loveIntro
