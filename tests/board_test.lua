context("board", function()
  before(function()
    board = require("columns.boards")({ w = 5, h = 10})
  end)

  test("iterates over all possible coordinates", function()
    counter = 0

    for x, y in board.allCoordinates() do
      counter = counter + 1
      assert_true(x >= 1 and x <= board.w)
      assert_true(y >= 1 and y <= board.h)
    end

    assert_equal(counter, board.area())
  end)

  test("iterates over all possible coordinates starting from a given line", function()
    yValues = { 4 }

    for x, y in board.allCoordinates(4) do
      if yValues[#yValues] ~= y then yValues[#yValues + 1] = y end
    end

    assert_equal(#yValues, 7) -- 4, 5, 6, 7, 8, 9, 10 == 7 lines.

    for i, v in ipairs(yValues) do
      assert_equal(i + 3, v)  -- lines 4 to 10
    end
  end)

  test("clears the entire board", function()
    board.clear(7)
    for x, y in board.allCoordinates() do assert_equal(board.get(x, y), 7) end
  end)

  test("knows if there is space in a determinated cell", function()
    board.clear()
    assert_true(board.isFree(1, 1))
    board.set(1, 1, "normal")
    assert_false(not not board.isFree(1, 1))
  end)
end)

--------------------------------------------------------------------------------

context("board matches", function()
  before(function()
    board = require("columns.boards")({ w = 5, h = 1 })
  end)

  local function countMatches(kind, minLength, setCallback)
    board.clear()
    setCallback()
    return board.findMatches(kind, minLength)
  end

  test("finds matches of length 3", function()
    assert_equal(0, countMatches("horz", 3, function()
      board.set(1, 1, "normal", { color = 1 })
      board.set(2, 1, "normal", { color = 1 })
    end))

    three = function()
      board.set(1, 1, "normal", { color = 1 })
      board.set(2, 1, "normal", { color = 1 })
      board.set(3, 1, "normal", { color = 1 })
    end
    assert_equal(3, countMatches("horz", 3, three))
    assert_equal(0, countMatches("horz", 4, three))

    threeMiddle = function()
      board.set(2, 1, "normal", { color = 1 })
      board.set(3, 1, "normal", { color = 1 })
      board.set(4, 1, "normal", { color = 1 })
    end
    assert_equal(3, countMatches("horz", 3, threeMiddle))
    assert_equal(0, countMatches("horz", 4, threeMiddle))

    threeEnd = function()
      board.set(board.w - 0, 1, "normal", { color = 1 })
      board.set(board.w - 1, 1, "normal", { color = 1 })
      board.set(board.w - 2, 1, "normal", { color = 1 })
    end
    assert_equal(3, countMatches("horz", 3, threeEnd))
    assert_equal(0, countMatches("horz", 4, threeEnd))
  end)

  test("finds matches of length 4", function()
    four = function()
      board.set(1, 1, "normal", { color = 1 })
      board.set(2, 1, "normal", { color = 1 })
      board.set(3, 1, "normal", { color = 1 })
      board.set(4, 1, "normal", { color = 1 })
    end
    assert_equal(4, countMatches("horz", 3, four))
    assert_equal(4, countMatches("horz", 4, four))
    assert_equal(0, countMatches("horz", 5, four))
  end)

  test("finds matches of length 5", function()
    five = function()
      board.set(1, 1, "normal", { color = 1 })
      board.set(2, 1, "normal", { color = 1 })
      board.set(3, 1, "normal", { color = 1 })
      board.set(4, 1, "normal", { color = 1 })
      board.set(5, 1, "normal", { color = 1 })
    end
    assert_equal(5, countMatches("horz", 3, five))
    assert_equal(5, countMatches("horz", 4, five))
    assert_equal(5, countMatches("horz", 5, five))
  end)

  test("bubbles up holes")
end)
