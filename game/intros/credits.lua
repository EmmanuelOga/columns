local K = require("game.constants")

local LG = love.graphics
local LM = love.mouse
local LU = require("utils.love")

local menus = require('game.menus')

local sound = require('game.sounds')
local loveUtils = require('utils.love')
local chunky = require('game.render.chunky')

local tweener = require('tweener.base')
local easing = require('tweener.easing')

local hsl = require('utils.hsl')

local function soundMenu(returnTo)
  local self = {}

  local img = LG.newImage("media/graphics/love-logo-512x256.png")

  local font = K.CREDITS_FONT
  local fh = font:getHeight('X')
  local separation = fh / 2

  local msgs = {
    {"Columns!",
    "A game made in Buenos Aires",
    " - emmanueloga.com - ",},

    {"Powered by the love framework",
    " - love2d.org -",},

    {"Music",
     "Satellite One - Purple, Motion Crew (1993)",
     "4u - IMPRESION (1996)",
     "Trancemission - IMPRESION (1996)",
     "Economical Thing - tw^te",
     "Morphine - .pulse (1999)",
     "Music - gryzor",},

    {"Music",
     "Classical Favorites 1 - Virt/Root",
     "Classical Favorites 2 - Virt",
     " (http://www.biglionmusic.com/) ",
     "Luminosity and Viscosity - Rushjet1",
     " (http://nsf.4x86.com/) "},

    {"Sound Effects",
    " - www.kyutwo.com/downloads/sfx/anime -",
    " - soundbible.com -",
    " - www.shockwave-sound.com -",
    " - www.pdsounds.org -",},

    {"Some sounds generated with",
    " - www.superflashbros.net/as3sfxr -",},

    {"Columns! is licensed under",
    "Creative Commons License",
    "Attribution 3.0 Unported (CC BY 3.0)",
    " - http://creativecommons.org/licenses/by/3.0/ - "},

    {"Thanks for playing Columns!"}
  }

  local lx, ly, dx, dy = math.random(SCREEN_WIDTH), math.random(SCREEN_HEIGHT), 256, -256

  local hue = 0
  local function tweensFor(index)
    local tweens, texts = {}, msgs[index]

    for i, text in ipairs(texts) do
      local t = tweener("forward")
      local w = font:getWidth(text)
      local x = (SCREEN_WIDTH - w) / 2
      local y = (SCREEN_HEIGHT - (fh + separation) * #texts) / 2 + (fh + separation) * (i - 1)

      local function randomOut()
        local r = math.random(4)
        local prop = {angle=math.random()*math.pi*4}

        if     r == 1 then prop.x, prop.y = math.random(SCREEN_WIDTH), -fh
        elseif r == 2 then prop.x, prop.y = math.random(SCREEN_WIDTH), SCREEN_HEIGHT+fh
        elseif r == 3 then prop.x, prop.y = -w, math.random(SCREEN_HEIGHT)
        else               prop.x, prop.y = SCREEN_WIDTH, math.random(SCREEN_HEIGHT)
        end

        return prop
      end

      local lastx
      if math.random(2) == 1 then lastx = -w * 2 else lastx = SCREEN_WIDTH + w * 2 end

      t.add(randomOut())
      t.add({x=x, y=y, angle=0}, 1, easing.outBounce)
      t.add({x=(lastx + x + w / 2)/3, y=y, angle=0}, #texts * 2)
      t.add({x=lastx, y=y, angle=math.random() * math.pi * 4}, 2, easing.outExpo)

      function t.render()
        LG.setFont(font)
        LG.setBlendMode("alpha")

        local p = t.get()
        LG.push()
        LU.rotateAround(p.x + w / 2, p.y + fh / 2, p.angle)

        local mx, my = lx / SCREEN_WIDTH - 0.5, ly / SCREEN_HEIGHT - 0.5
        LG.setColor(0, 0, 0, 212)
        LG.print(text, p.x + (fh / 2) * -mx, p.y + (fh / 2) * -my)

        LG.setColor(hsl(hue, 1, 0.5))
        LG.print(text, p.x, p.y)
        LG.pop()
      end

      tweens[#tweens + 1] = t
    end

    return tweens
  end

  self.onEnter = function()
    sound.bgm("morphine"); chunky.setMode("drops")
  end

  local msgIdx, anim = 1, tweensFor(1)

  function self.draw()
    LG.setBlendMode("alpha")
    LG.setColor(255, 255, 255, 255)
    LG.push()
    LU.scaleAround(SCREEN_WIDTH - 128, SCREEN_HEIGHT - 64, 0.25)
    LG.draw(img, SCREEN_WIDTH - 128, SCREEN_HEIGHT - 64)
    LG.pop()

    LG.setBlendMode("multiplicative")
    for i = 25, 1, -1 do
      LG.setColor(255, 255, 255, easing.linear(25 - i, 232, 255 - 232, 25))
      LG.circle("fill", lx, ly, i * SCREEN_WIDTH / 100, i * 10)
    end

    for _, tween in ipairs(anim) do tween.render() end

    local small = K.SMALL_FONT
    LG.setFont(small)
    LG.setBlendMode("alpha")
    LG.setColor(128, 128, 128)
    LG.print(" version " .. COLUMNS_VERSION, 0, SCREEN_HEIGHT - small:getHeight(" "))
  end

  local iterations = 0
  function self.update(dt)
    hue = hue + dt / 10
    for _, tween in ipairs(anim) do tween.update(dt) end

    lx, ly = lx + dt * dx, ly + dt * dy
    if lx > SCREEN_WIDTH or lx < 0 then dx = -dx; lx = lx + dt * dx * 2 end
    if ly > SCREEN_HEIGHT or ly < 0 then dy = -dy; ly = ly + dt * dy * 2 end

    if anim[1].finished() then
      msgIdx = msgIdx + 1

      if msgIdx > #msgs then
        msgIdx, iterations = 1, iterations + 1

        if iterations == 1 then
          msgs[#msgs + 1] = {"Exactly...", "how many times", "do you plan to watch", "these credits?"}
        end

        if iterations == 2 then
          msgs[#msgs + 1] = {"You are", "a persistent one", "eh?"}
          msgs[#msgs + 1] = {"Ok, ok", "there was a secret", "message.", "You got that right."}
          msgs[#msgs + 1] = {"As a reward", "for your persistence,", "here is a clue:", "KONAMI"}
        end

        if iterations == 3 then
          msgs[#msgs + 1] = {"Hey pal, thanks for watching this", iterations .. " TIMES!!!", "Doctor says", "no more eastern eggs for you."}
        end

        if iterations > 3  then
          msgs[#msgs] = {"Hey pal, thanks for watching this", iterations .. " TIMES!!!", "Doctor says", "no more eastern eggs for you."}
        end
      end

      anim = tweensFor(msgIdx)
    end
  end

  function self.keypressed(key)
    if key == "escape" then return returnTo end
  end

  return self
end

return soundMenu
