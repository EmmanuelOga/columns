local K = require('game.constants')
local LG = love.graphics

local timing = require('utils.timing')
local sounds = require('game.sounds')

local bt     = require('game.render.bursts')
local osd    = require('game.render.osd')
local chunky = require('game.render.chunky')

local rboard   = require('game.render.gems.board')
local rhud     = require('game.render.hudSingle').render
local rinfo    = require('game.render.hud.info')
local rthunder = require('game.render.thunder')

local random = math.random

local function singlePlayer(levelNumber, prevScores)
  local over, won, fatal = false, false, false
  local board        = require('columns.boards')({ w=K.BOARD_WIDTH, h=K.BOARD_HEIGHT })
  local level        = require('game.levelLoader')(board, levelNumber or 1)
  local self         = {level=level, board=board, scores=(prevScores or require('game.scoreKeeper')())}
  local messages     = require("game.messages")()
  local quake        = require("game.quake")()
  local column       = level.newColumn(board)
  local nextColumn   = level.newColumn(board)
  local countDown    = require("game.countDown")(level.countDownSpeed)
  local gravityTimer = timing.interval(0.1, function(dt) board.bubbleUpHoles(dt) end)

  -- on levels with timer enabled this rises the floor when x time elapses.
  countDown.callback = function() fatal = not board.floorUp(); column.pushUp(); sounds.sfx("floor") end

  -- this pushes down the column, and checks for the first "collision" to play a sound.
  local function pushDown(dt, manual)
    local prevY, first  = column.y, column.pushDown(dt)
    if manual and column.y > prevY then self.scores.slowDropBonus() end
    if first then sounds.sfx("drop", random() * 0.5 + 1.5) end
  end

  -- a little less boredom in the endless mode. Randomize the bg every while.
  local chunkySetter
  if self.level.number == "endless" then
    chunkySetter = timing.interval(60 * 5, function() level.background = chunky.randomMode() end)
  end

  -- make the column fall. Keeping it on top all the time is boring, isn't it?
  local downTimer = timing.interval(K.COLUMN_FALL_SPEED,
    function(_, _, elapsed)
      if not (won or over) and not board.hasUnestableColumns() then pushDown(elapsed) end
    end,
    function(total, _, _, left)
      if not (won or over) then
        if not board.hasUnestableColumns() then column.left = left / total end -- left is time left to fall, used to make the column slide down smoothly.
      end
    end
  )

  -- this is invoked for each gem destroyed or about to be destroyed (matched)
  local function destroyGemCallback(x, y, b, definitive)
    if definitive then
      sounds.sfx("destroy")
      if b.burn then rthunder.trigger() end
    else
      sounds.sfx("crackers")
    end

    if bt and y > K.HIDDEN_LINES then
      if b.color then
        bt.explode(b.color, x, y - K.HIDDEN_LINES, K.PARTICLES_EMISSION_TIME)
      else
        local even_or_odd = random(2) -- let's try to emit less particles
        for i = 1, K.NUM_GEMS do
          if i % 2 == even_or_odd then
            bt.explode(i, x, y - K.HIDDEN_LINES, K.PARTICLES_EMISSION_TIME / (K.NUM_GEMS * 10) )
          end
        end
      end
    end
  end

  -- this is called once each time there are destroys > 0
  local function destroyMatchesCallback(dt, destroys)
    countDown.reset()
    quake.shake(destroys * 0.1)
  end

  local MAX_SONG_SECONDS = 60 * 5 -- do not bore the player.
  self.onEnter = function()
    if self.level.number == "endless" then sounds.shuffleTime = MAX_SONG_SECONDS end
    chunky.setMode(level.background)
    sounds.bgm(level.music)
    osd.clear()
    self.scores.resume()
  end

  self.onExit = function()
    sounds.shuffleTime = false -- make sure shuffle gets reseted after exiting the game state.
    osd.clear()
    self.scores.resetComboCount()
    self.scores.pause()
  end

  local renderBoard = rboard.render
  self.draw = function()
    LG.push()

    if K.SHAKE_ENABLED then quake.apply() end
    rhud({ time = countDown.current, level = level, info = messages.info, nextColumn = nextColumn, stats = board.stats(), danger = board.dangerous() })
    renderBoard(board, column, K.SINGLE.BOARD.x, K.SINGLE.BOARD.y)

    LG.setBlendMode("additive")
    if K.PARTICLES_ENABLED then bt.render(K.SINGLE.BOARD.x, K.SINGLE.BOARD.y) end

    rthunder.render()

    LG.setBlendMode("additive")
    osd.render()

    self.scores.render(K.SINGLE.SCORE.x, K.SINGLE.SCORE.y)
    LG.pop()
  end

  -- this handle the placement of the column and the switch to the next one.
  -- if the column cannot be placed, the game is over.
  local function checkColumnPlacement()
    if column.laying > K.COLUMN_LAY_TIME then
      if column.place() then
        if column.drop then self.scores.quickDropBonus() end
        nextColumn.x = column.x
        column, nextColumn = nextColumn, level.newColumn(board)
        self.scores.resetComboCount()
      else
        fatal = true
      end
    end
  end

  -- we need to call this continuosly to make combos work (can happen even if no new column is lay down)
  -- but no need to call it every frame.
  local scoringTimer = timing.interval(0.25, function()
    if not (won or over) then
      if board.hasUnestableColumns() then return end -- wait until all gems have settle down.
      checkColumnPlacement() -- check if a reset of combo counter is needed first.
      self.scores.findMatches()
    end
  end)

  local dropTimer = timing.interval(1/60, function(_, _, elapsed)
    if column.drop then for i = 1, 4 do pushDown(1) end end
  end)

  local TIMERS = {gravityTimer, downTimer, scoringTimer, chunkySetter, dropTimer}
  local UPDATABLES = {
    osd, quake, rinfo, column, bt, rthunder, rboard, self.scores,
    require("game.render.gems.arrows"), require('game.render.gems.burn'), require("game.render.globalTweens")
  }
  self.update = function(dt)
    if won or (osd.size() == 0) then chunky.setMode(level.background) end

    for _, t in pairs(TIMERS) do if t then t(dt) end end
    for _, u in pairs(UPDATABLES) do if u then u.update(dt) end end

    -- oh-oh.
    if not (won or over) and fatal then self.addMessage("Game Over!", true); over = true end
    if over then
      if osd.empty() then
        return require('game.menus.gameOver')(self)
      else
        return -- EXIT POINT
      end
    end

    if not (won or over) and level.timer then countDown.update(dt) end

    checkColumnPlacement()

    -- this performs the actual destroys, the blocks have a count down to destruction that needs to be updated continuosly.
    destroys = board.destroyMatches(dt, destroyGemCallback)
    if destroys > 0 then destroyMatchesCallback(dt, destroys) end

    if not won and not over and not column.fits() then sounds.sfx("nonfit") end

    -- when the objectives of the level are met it is time to switch to the next one.
    if not (won or over) and not board.hasUnestableColumns() and level.checkObjectives(self) then
      self.addMessage("You Won!", true); won = true
    end
    if won then if osd.empty() then return require("game.menus.next")(self) end end
  end

  -- handle input.
  love.keyboard.setKeyRepeat(100, 100)
  self.keypressed = function(key, unicode)
    if key == 'escape' then return require('game.menus.pause')(self) end

    if won or over then return end

    self.scores.keyPress()

    if key == K.KEYS_SINGLE.DROP  then column.drop = true; sounds.sfx("drop", 1.1) end
    if key == K.KEYS_SINGLE.RUP   then column.rotateUp(); sounds.sfx("rotate", 1.1) end
    if key == K.KEYS_SINGLE.RDOWN then column.rotateDown(); sounds.sfx("rotate", 1.1) end
    if key == K.KEYS_SINGLE.DOWN  then pushDown(0.1, true) end
    if key == K.KEYS_SINGLE.LEFT  then if column.pushLeft() then sounds.sfx("rotate", 2.1) end end
    if key == K.KEYS_SINGLE.RIGHT then if column.pushRight() then sounds.sfx("rotate", 2.2) end end
  end

  -- info window. Used by score keeper to inform things.
  self.addMessage = function(msg, high)
    if high then osd.add(msg, function() rthunder.trigger() end) end
    rinfo.colorReset()
    messages.add(msg)
  end

  level.initBoard(board)
  self.scores.setGame(self)

  return self
end

return singlePlayer
