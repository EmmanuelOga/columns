local K = require("game.constants")
local LG = love.graphics

local renderNext = require('game.render.hud.next')
local renderStats = require('game.render.hud.stats')
local renderTimer = require('game.render.hud.timer')
local renderLevel = require('game.render.hud.level')
local renderInfo = require('game.render.hud.info')

local GT = require("game.render.globalTweens")

local function renderAll(data)
  LG.setFont(K.DEFAULT_FONT)

  local top = K.COLUMN_HEIGHT * K.GEM_SIZE

  LG.setBlendMode("alpha")
  LG.setColor(0, 0, 0, 64)
  LG.rectangle("fill", K.SINGLE.BOARD.x, K.SINGLE.BOARD.y, K.SINGLE.BOARD.w, K.SINGLE.BOARD.h)

  -- 'danger zone'
  LG.setBlendMode("alpha")
  if data.danger then LG.setColor(GT.red(), 0, 0, 64) else LG.setColor(0, 0, 255, 64) end
  LG.rectangle("fill", K.SINGLE.BOARD.x + 2, K.SINGLE.BOARD.y + 2, K.SINGLE.BOARD.w - 4, top - 4)

  local x1 = K.SINGLE.BOARD.x + 2
  local x2 = x1 + K.SINGLE.BOARD.w - 4
  local y = K.SINGLE.BOARD.y + 2 + top - 4

  LG.setLine(2, "rough")
  LG.setLineStipple(0x0ff0)

  LG.setColor(255, 255, 255, 64)
  LG.line(x1, y, x2, y)

  LG.setLineStipple(0xffff)
  LG.setColor(255, 255, 255, 128)
  LG.rectangle("line", K.SINGLE.BOARD.x, K.SINGLE.BOARD.y, K.SINGLE.BOARD.w, K.SINGLE.BOARD.h)

  if K.SHOW_STATS     then renderStats(data.stats, K.SINGLE.STATS) end
  if K.SHOW_NEXT      then renderNext(data.nextColumn, K.SINGLE.NEXT) end

  if data.level.timer then
    renderTimer(data.time, K.SINGLE.TIMER)
    renderLevel(data.level, K.SINGLE.LEVEL)
    if K.SHOW_INFO then renderInfo.render(data.info, K.SINGLE.INFO) end
  else
    -- as the timer is not here, we can move things up to fill the space better.
    renderLevel(data.level, K.SINGLE.LEVEL_NO_TIMER)
    if K.SHOW_INFO then renderInfo.render(data.info, K.SINGLE.INFO_NO_TIMER) end
  end

end

return {
  render = renderAll,
}
