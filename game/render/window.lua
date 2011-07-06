local K = require("game.constants")
local LG = love.graphics
local GT = require("game.render.globalTweens")

local function renderWindow(label, coords, callback, high)
  LG.push()
  LG.translate(coords.x, coords.y)
  LG.setFont(K.DEFAULT_FONT)
  LG.setLine("2", "smooth")
  LG.setBlendMode("alpha")

  local titleOffset = K.DEFAULT_FONT:getWidth(" ") / 2

  if high then
    LG.setColor(GT.red(), 0, 0, 96)
  else
    LG.setColor(0, 0, 0, 96)
  end

  LG.rectangle("fill", 0, 0, coords.w, coords.h) -- base panel

  LG.setLine(2, "rough")
  LG.setColor(255, 255, 255, 128)
  LG.rectangle("line", 0, 0, coords.w, coords.h)

  LG.setColor(255, 255, 255, 232)
  LG.print(label, titleOffset, titleOffset)

  if callback then
    local contentOffset = titleOffset + K.DEFAULT_FONT:getHeight(" ")
    LG.translate(titleOffset, contentOffset)
    callback(coords.w - 2 * titleOffset, coords.h - contentOffset - titleOffset - 1)
  end

  LG.pop()
end

return {
  render = renderWindow,
}
