local function levelLoader(board, number)
  local source

  if number == "endless" then
    source = 'levels/endless.lua'
  else
    source = string.format('levels/%03d.lua', number)
  end

  print("looking for: ", source)
  if love.filesystem.isFile(source) then
    source = love.filesystem.read(source)
  else
    return false
  end

  -- TODO there might be a better way to do this.
  source = [[
    local board = ...

    local K = require("game.constants")
    local gems = require("columns.gems")
    local columns = require("columns.columns")

    local helpers = require('game.levelHelpers')
    local probability = helpers.probability
    local mapParser = helpers.mapParser

    local random = math.random

    local function initColumn()
      return columns{
        board = board,
        gems.normal{color = random(K.NUM_GEMS)},
        gems.normal{color = random(K.NUM_GEMS)},
        gems.normal{color = random(K.NUM_GEMS)},
      }
    end

    local function levelDefinition()
  ]] .. source .. [[
    end

    local level = levelDefinition()

    local levelNewColumn = level.newColumn
    level.newColumn = function() return levelNewColumn(initColumn()) end

    level.initBoard = function(board)
      if board and level.boardMap then mapParser(board, level.boardMap()) end
      return board
    end

    return level
  ]]

  return loadstring(source)(board)
end

return levelLoader
