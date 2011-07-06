local K = require("game.constants")
local LG = love.graphics
local LM = love.mouse

local hsl = require('utils.hsl')
local sounds = require('game.sounds')

local tweener = require('tweener.base')
local easing = require('tweener.easing')

-- factory function for menus.
local function menus(x0, y0, separation, initialSelection)
  local SELECTED_ANIM_TIME = 0.75

  local self = {x0=x0, y0=y0, separation=separation, start=1}
  local items, selected, activate = {}
  local moreUp, moreDown -- these are the more options outside the menu to allow the mouse to scroll up/down

  local function setMousePosition()
    if selected then
      local h = K.MENUS_FONT:getHeight(" ")
      LM.setPosition(LM.getX(), (selected - self.start) * h * self.separation + h / 2 + self.y0)
    end
  end

  local function newItem(label, callback)
    local self = {callback=callback, item=true}

    -- if the label is a table then is a bunch of options to scrolldown
    if type(label) == "string" then
      self.label = label
    else
      self.label, self.options, self.selection, self.multiple = label[1].label, label, 1, true
      self.offsetRot = 0 -- for animation of value selection
      self.data = self.options[1].data

      for i, option in ipairs(self.options) do
        if option.selected then
          self.label, self.selection, self.data = self.options[i].label, i, self.options[i].data
          break
        end
      end

      -- private, for switching multiple selections in multiple choice items.
      local function switchSelection(direction)
        self.selection = self.selection + direction
        if self.selection < 1 then self.selection = #self.options
        elseif self.selection > #self.options then self.selection = 1 end
        self.label, self.data = self.options[self.selection].label, self.options[self.selection].data

        self.offsetRot = -direction * SCREEN_WIDTH / 2
        self.tweensRot.setCurrent(1) -- animate.

        return activate()
      end

      self.left = function() return switchSelection(-1) end
      self.right = function() return switchSelection(1) end
    end

    self.tweens = tweener("forward")
    self.tweens.add({x = 0})
    self.tweens.add({x = 1}, SELECTED_ANIM_TIME, easing.outElastic)

    self.tweensRot = tweener("forward")
    self.tweensRot.add({x = 1})
    self.tweensRot.add({x = 0}, SELECTED_ANIM_TIME, easing.outBack)

    return self
  end

  local function newTitle(label)
    local self = {label=label, title=true}
    return self
  end

  local function anyItems()
    for _, item in ipairs(items) do if item.item then return true end end
    return false
  end

  local function nextItemIndex(direction)
    local i = selected and ( selected + direction ) or 1
    while i > 0 and i <= #items and ( not items[i] or not items[i].item ) do i = i + direction end
    if i > #items then for i, v in ipairs(items) do if v.item then return i end end -- return first non title.
    elseif i == 0 then for i = #items, 1, -1 do if items[i].item then return i end end -- return first non title.
    else return i
    end
  end

  local function selectItem(index, keyboard)
    if not anyItems() then return end

    if index and index > 0 and index <= #items and selected ~= index then
      if selected then
        items[selected].tweens.setCurrent(1)

        if index < self.start then
          self.start = index
        elseif index >= self.start + K.MAX_MENU_ITEMS then
          self.start = index - K.MAX_MENU_ITEMS + 1
        end
      end

      if items[index] and items[index].item then
        sounds.sfx("menu")
        selected = index
        items[selected].tweens.setCurrent(1)

        if keyboard then setMousePosition() end
      end
    end
  end

  local function add(label, callback)
    local item = newItem(label, callback)
    items[#items + 1] = item
    return item
  end

  local function title(label, callback)
    items[#items + 1] = newTitle(label)
  end

  -- iterator, return an index from 1 to the item number, and from self.start to self.start + last visible item.
  local function visibleIndexes()
    if #items > K.MAX_MENU_ITEMS then
      start = self.start
      finish = math.min(start + K.MAX_MENU_ITEMS - 1, #items)
    else
      start, finish = 1, #items
    end
    local i, j = 0, start - 1
    return function()
      if j < finish then
        i, j = i + 1, j + 1
        return i, j
      end
    end
  end

  local selColor = 0
  local function renderItem(label, x, y, sel)
    local shadow = K.MENUS_FONT:getHeight(" ") / 8
    LG.setColor(0, 0, 0, 128)
    LG.print(label, x + shadow, y + shadow)
    if sel then LG.setColor(hsl(selColor, 1, 0.5)) else LG.setColor(K.MENU_UNSELECTED_FG) end
    LG.print(label, x, y)
  end

  -- render the menu on position x0, y0.
  local function render(x0, y0)
    LG.setFont(K.MENUS_FONT)
    self.x0, self.y0 = x0, y0

    local x, y, offset, item, start, finish

    local H = K.MENUS_FONT:getHeight(" ")

    for i, j in visibleIndexes() do
      item = items[j]

      y = (i - 1) * H * self.separation + self.y0

      if item.item then
        x, offset = self.x0 + K.MENU_SELECTED_OFFSET, item.tweens.getCurrentProperties().x * K.MENU_SELECTED_OFFSET

        if j == selected then
          if item.multiple then
            local offsetRot = item.tweensRot.getCurrentProperties().x * item.offsetRot
            renderItem(item.label, offsetRot + ( SCREEN_WIDTH - K.MENUS_FONT:getWidth(item.label) ) / 2, y, j == selected)
            LG.print(" <", 0, y); LG.print("> ", SCREEN_WIDTH - K.MENUS_FONT:getWidth("> "), y)
          else
            if i == #items and #items > 1 then -- a little convention, last item in general is for going up or exiting.
              renderItem("<" .. item.label, x + offset, y, j == selected)
            else
              renderItem(">" .. item.label, x + offset, y, j == selected)
            end
          end
        else
          renderItem(item.label, x - offset, y, j == selected)
        end

      elseif item.title and item.label ~= "" then
        renderItem(item.label, (SCREEN_WIDTH - K.MENUS_FONT:getWidth(item.label)) / 2, y, false)
      end
    end

    if #items > K.MAX_MENU_ITEMS then
      if self.start > 1 then -- display the more button on top
        x, offset = self.x0 - K.MENU_SELECTED_OFFSET, moreUp.tweens.getCurrentProperties().x * K.MENU_SELECTED_OFFSET
        y = (-1) * H * self.separation + self.y0
        renderItem(moreUp.label, x + offset, y, moreUp.selected)
      end

      if self.start + K.MAX_MENU_ITEMS - 1 < #items then -- display the more button on bottom
        x, offset = self.x0 - K.MENU_SELECTED_OFFSET, moreDown.tweens.getCurrentProperties().x * K.MENU_SELECTED_OFFSET
        y = (K.MAX_MENU_ITEMS) * H * self.separation + self.y0
        renderItem(moreDown.label, x + offset, y, moreDown.selected)
      end
    end
  end

  local function checkMousePosition()
    local my, H, normal = LM.getY(), K.MENUS_FONT:getHeight(" "), false

    local function checkIndex(index)
      local y = (index - 1) * H * self.separation + self.y0
      return my >= y and my <= y + H
    end

    for i, j in visibleIndexes() do
      if checkIndex(i) then
        normal = true
        if items[j] and items[j].item then selectItem(j) end
        break
      end
    end

    if #items > K.MAX_MENU_ITEMS then
      if normal then
        moreUp.selected = false; moreDown.selected = false

      elseif checkIndex(K.MAX_MENU_ITEMS + 1) then
        moreUp.selected = false; moreDown.selected = true

      elseif checkIndex(0) then
        moreUp.selected = true; moreDown.selected = false
      end
    end
  end

  local function mousepressed()
    local current = items[selected]

    checkMousePosition()

    if moreUp.selected then moreUp.tweens.setCurrent(1); moreUp.callback()
    elseif moreDown.selected then moreDown.tweens.setCurrent(1); moreDown.callback()
    elseif current and current.multiple then
      if LM.getX() > SCREEN_WIDTH / 2 then current.right() else current.left() end
    elseif current then return activate()
    end
  end

  local function keypressed(key)
    if     key == 'up'     then selectItem(nextItemIndex(-1), true)
    elseif key == 'down'   then selectItem(nextItemIndex(1), true)
    elseif key == 'left'   then if items[selected] and items[selected].multiple then items[selected].left() end
    elseif key == 'right'  then if items[selected] and items[selected].multiple then items[selected].right() end
    elseif key == 'return' then return activate()
    elseif key == 'escape' then selectItem(#items); return activate() -- a little convention, on ESC run last item.
    end
  end

  local function update(dt)
    selColor = selColor + dt / 10
    for _, item in ipairs(items) do
      if item.tweens then item.tweens.update(dt) end
      if item.tweensRot then item.tweensRot.update(dt) end
    end
    moreUp.tweens.update(dt)
    moreDown.tweens.update(dt)
    checkMousePosition()
  end

  activate = function()
    sounds.sfx("menu")
    local current = items[selected]
    return current and current.callback and current.callback(current.data)
  end

  self.add = add
  self.title = title
  self.update = update
  self.render = render
  self.keypressed = keypressed
  self.mousepressed = mousepressed
  self.activate = activate
  self.selectPrev = function() selectItem((selected or 1) - 1, true) end
  self.selectNext = function() selectItem((selected or 1) + 1, true) end
  self.selectItem = selectItem
  self.currentSelection = function() return selected end
  self.setMousePosition = setMousePosition

  moreUp = newItem("..more..", function()
    if self.start - 1 > 0 then
      self.start = self.start - 1; sounds.sfx("menu")
    end
  end)

  moreDown = newItem("..more..", function()
    if self.start < #items - K.MAX_MENU_ITEMS + 1 then
      self.start = self.start + 1; sounds.sfx("menu")
    end
  end)

  self.selectItem(initialSelection)

  return self
end

return menus
