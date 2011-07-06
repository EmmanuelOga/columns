local mapParser = require("game.levelHelpers").mapParser

context("dynArray", function()
  before(function()
    board  = require('columns.boards')({ w=9, h=10 })

    boardMap = function()
      return [[
        | . 1 . 1 . . . . . |
        | . 2 . 2 . . . . . |
        | . 1 . 1 . . . . . |
      ]]
    end
  end)

  test("parses each line", function()
    mapParser(board, boardMap())
    assert_equal(board.get(2, 8).color, 1)
    assert_equal(board.get(2, 9).color, 2)
    assert_equal(board.get(2,10).color, 1)
    assert_equal(board.get(4, 8).color, 1)
    assert_equal(board.get(4, 9).color, 2)
    assert_equal(board.get(4,10).color, 1)
  end)
end)
