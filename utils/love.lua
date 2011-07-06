-- Some helpers around löve functions.
local LG = love.graphics

-- rotates the scene around the given x,y point.
local function rotateAround(x, y, angle)
  if angle and angle ~= 0 then
    LG.translate(x, y)
    LG.rotate(angle)
    LG.translate(-x, -y)
  end
end

-- scale around the given x,y point.
local function scaleAround(x, y, scale)
  if scale and scale ~= 1 then
    LG.translate(x, y)
    LG.scale(scale)
    LG.translate(-x, -y)
  end
end

-- this prints a text on the y coordinate centered across the screen.
-- for some reason I cannot get the same results with love.graphics.printf
local function printCenter(text, y)
  local f = LG.getFont()
  local x = ( SCREEN_WIDTH - f:getWidth(text) ) / 2

  local offset = f:getWidth("X") / 10
  local r, g, b, a = love.graphics.getColor()

  LG.setColor(0, 0, 0)
  LG.print(text, x + offset, y + offset)

  LG.setColor(r, g, b, a)
  LG.print(text, x, y)
end

return {
  rotateAround = rotateAround,
  scaleAround = scaleAround,
  printCenter = printCenter,
}
