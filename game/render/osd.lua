local K = require("game.constants")
local LG = love.graphics

local hsl = require("utils.hsl")
local buffer = require('utils.buffer')

local tweener = require('tweener.base')
local easing = require('tweener.easing')

local function osd()
  local queue = {}

  local function add(message, callback)
    local f = K.OSD_FONT

    local w = f:getWidth(message)
    local h = f:getHeight(message)
    local x = (SCREEN_WIDTH - w) / 2
    local y = (SCREEN_HEIGHT - h) / 2

    local t = tweener("forward")

    t.add({ x = x, y = -h, start = true  })
    t.add({ x = x, y = y }, easing.outBounce, 0.75)
    t.add({ x = x, y = y }, 2.25)
    t.add({ x = x, y = SCREEN_HEIGHT + h }, easing.inOutBack, 0.75)

    queue[#queue + 1] = { message = message, t = t, callback = callback }
  end

  local function clear()
    queue = {}
  end

  local function processFirst(dt)
    if queue[1].t.update(dt) then table.remove(queue, 1) end
  end

  local function update(dt)
    -- if more than 1 elements are left, process them faster.
    if #queue > 1 then processFirst(dt * #queue * 2)
    elseif #queue > 0 then processFirst(dt)
    end
  end

  local function render()
    if #queue > 0 then
      local f = K.OSD_FONT
      local offset = f:getWidth("X") / 10

      local m = queue[1]
      local p = m.t.getCurrentProperties()

      if p.start and m.callback and m.t.getElapsed() > 0.25 and not m.callbackCalled then
        m.callback()
        m.callbackCalled = true
      end

      -- with printf lines may span more than one line
      local yLine = math.ceil(f:getWidth(m.message) / SCREEN_WIDTH) * f:getHeight("X") / 3

      LG.setFont(f)
      LG.setBlendMode("alpha")
      LG.setColor(0, 0, 0, 128)
      LG.printf(m.message, 0, p.y + offset - yLine, SCREEN_WIDTH, "center")
      --LG.print(m.message, p.x + offset, p.y + offset)

      LG.setBlendMode("additive")
      LG.setColor(255, 255, 255, 212)
      LG.printf(m.message, 0, p.y - yLine, SCREEN_WIDTH, "center")
      --LG.print(m.message, p.x, p.y)
    end
  end

  local function empty()
    return #queue == 0
  end

  local function size()
    return #queue
  end

  return {
    empty = empty,
    size = size,
    add = add,
    clear = clear,
    update = update,
    render = render
  }
end

return osd()
