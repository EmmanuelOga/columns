local pairs, ipairs = pairs, ipairs

local namespace = {
  processBurn = require("columns.gems.burn"),
  processBomb = require("columns.gems.bomb"),

  -- This function knows whether two consecutive gems are a match or not.
  -- It gets a little hairy when you need to deal with wildcards, a lot of corner cases.
  isMatch = function(board, coords, i)
    local function getGem(offset)
      local index = i + offset

      if index > 0 and index <= #coords then
        if not board.isFloating(coords[index]) then -- do not match gems that are "floating"
          local b = board.get(coords[index])

          -- gems with stays > 1 get cleared more than once if they are matched in more than one direction.
          if not (b.stays and b.stays > 1 and b.destroy) then return b end
        end
      end
    end

    local current = getGem(0)

    if not current then return false end

    local next1 = getGem(1)

    if current.hole or (next1 and next1.hole) then return false end

    local next2 = getGem(2)
    local prev1 = getGem(-1)
    local prev2 = getGem(-2)

    if current.normal and next1 and next1.normal then
      return current.color == next1.color

    elseif current.normal and prev1 and prev1.wild then
      return (prev2 and (prev2.wild or prev2.color == current.color)) or
             (next1 and (next1.wild or next1.color == current.color))

    elseif current.normal and next1 and next1.wild then
      return (next2 and (next2.wild or next2.color == current.color)) or
             (prev1 and (prev1.wild or prev1.color == current.color))

    elseif current.wild then
      if ( next1 and next1.wild ) or
         ( next1 and next1.normal and next2 and next2.wild) then return true end

      return ( prev1 and next1 and (prev1.color == next1.color )) or
             ( next1 and next2 and (next1.color == next2.color ))
     end

     return false
  end,
}

-- Adds gem factories to the namespace.
local function setupFactory(kind, initializer)
  namespace[kind] = function(...)
    local gem = {kind = kind} -- setmetatable({kind = kind}, gemMetatable)
    gem[kind] = true -- allow things like: gem.normal instead of gem.kind == "normal"
    if initializer then initializer(gem, ...) end
    return gem
  end
end

-- options for normal gems:
-- stays: number of times before it "explodes"
-- color: color of the gem (or type of gem)
-- bomb: a string with letters indicating the direction of the bomb
--   1 u 2
--   l   r
--   3 d 4
-- fixed: whether the gem falls under "gravity" or not
-- selected: whether ther gem is selected as a level objective or not
setupFactory("normal", function(gem, options)
  options = options or {}
  gem.matched = nil
  gem.stays = options.stays or 1
  gem.color = options.color or 1 -- a little boring no?
  gem.fixed = options.fixed
  gem.bomb = options.bomb
  gem.selected = options.selected
end)

setupFactory("hole")     -- this chould had been just nil, but I don't mind being consistent.
setupFactory("wild")     -- wildcard matches other wildcards or any normal gem
setupFactory("burn")     -- remove every gem of the kind below it.
setupFactory("obstacle") -- obstacle does not match anything
setupFactory("fixed")    -- fixed does not match anything and is not affected by "gravity". Is like a wall, part of the board.

return namespace
