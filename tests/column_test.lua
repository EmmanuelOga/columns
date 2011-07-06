local gems = require "columns.gems"
local columns = require "columns.columns"
local boards = require "columns.boards"

context("column", function()

  before(function()
    board = boards{ w = 8, h = 20 }

    gem1 = gems.normal{ color = 1 }
    gem2 = gems.normal{ color = 2 }
    gem3 = gems.normal{ color = 3 }

    column = columns{ gem1, gem2, gem3, board = board }
  end)

  test("can get all the column coordinates", function()
    returns = {}

    for x, y, b in column.allCoordinates() do
      returns[#returns + 1] = { x, y, b }
    end

    local function assert_table_elements_equal(n, table1, table2)
      for i = 1, n do
        assert_equal(table1[i], table2[i])
      end
    end

    assert_table_elements_equal(3, returns[1], { 4, 1, gem1 })
    assert_table_elements_equal(3, returns[2], { 4, 2, gem2 })
    assert_table_elements_equal(3, returns[3], { 4, 3, gem3 })
  end)

  test("can get and set a gem", function()
    assert_equal(column[1], gem1)
    assert_equal(column[2], gem2)
    assert_equal(column[3], gem3)

    column[1] = gem1
    column[2] = gem1
    column[3] = gem1

    assert_equal(column[1], gem1)
    assert_equal(column[2], gem1)
    assert_equal(column[3], gem1)
  end)

  test("can rotate a column up", function()
    column.rotateUp()
    assert_equal(column[1], gem2)
    assert_equal(column[2], gem3)
    assert_equal(column[3], gem1)

    column.rotateUp()
    assert_equal(column[1], gem3)
    assert_equal(column[2], gem1)
    assert_equal(column[3], gem2)

    column.rotateUp()
    assert_equal(column[1], gem1)
    assert_equal(column[2], gem2)
    assert_equal(column[3], gem3)
  end)

  test("can rotate a column down", function()
    column.rotateDown()
    assert_equal(column[1], gem3)
    assert_equal(column[2], gem1)
    assert_equal(column[3], gem2)

    column.rotateDown()
    assert_equal(column[1], gem2)
    assert_equal(column[2], gem3)
    assert_equal(column[3], gem1)

    column.rotateDown()
    assert_equal(column[1], gem1)
    assert_equal(column[2], gem2)
    assert_equal(column[3], gem3)
  end)

  test("can be pushed left and right inside the limits of the board width", function()
    for x = 1, ( board.w + 2 ) do
      column.pushLeft()
    end
    assert_equal(column.x, 1)

    for x = 1, ( board.w + 2 ) do
      column.pushRight()
    end
    assert_equal(column.x, board.w)
  end)

  test("knows when is laying over something", function()
    assert_false(column.isLaying())
    board.set(column.x, column.y + 4, columns{ color = 2 })
    assert_false(column.isLaying())
    board.set(column.x, column.y + 3, columns{ color = 2 })
    assert_true(column.isLaying())
    column.y = board.h - 2
    assert_true(column.isLaying())
  end)

  context("being pushed", function()
    context("on an empty board", function()
      test("can be push down until it reaches the bottom", function()
        for i = 1, board.h - 3 do
          column.pushDown()
          assert_equal(column.y, i + 1)
        end

        assert_false(not not column.pushDown())
      end)

      test("can be push up until it reaches the top", function()
        for i = 1, board.h - 3 do column.pushDown() end

        for i = board.h - 3, 1, -1 do
          local newY = column.pushUp()
          assert_equal(type(newY), "number")
          assert_equal(newY, i)
          assert_equal(column.y, i)
        end

        assert_false(column.pushUp())
        assert_equal(column.y, 1)
      end)
    end)

    context("on an filled board", function()
      before(function()
        board.set(4, 10, "normal")
      end)

      test("it goes down until it hits a gem", function()
        column.x = 4
        column.y = 6
        column.pushDown(); column.pushDown(); column.pushDown()
        assert_equal(column.y, 7)
      end)

      test("it goes left until it hits a gem", function()
        column.x = 5; column.y = 8
        column.pushLeft()
        assert_equal(column.x, 5)

        column.x = 5; column.y = 9
        column.pushLeft()
        assert_equal(column.x, 5)

        column.x = 5; column.y = 10
        column.pushLeft()
        assert_equal(column.x, 5)

        column.x = 5; column.y = 11
        column.pushLeft()
        assert_equal(column.x, 4)
      end)

      test("it goes right until it hits a gem", function()
        column.x = 3; column.y = 8
        column.pushRight()
        assert_equal(column.x, 3)

        column.x = 3; column.y = 9
        column.pushRight()
        assert_equal(column.x, 3)

        column.x = 3; column.y = 10
        column.pushRight()
        assert_equal(column.x, 3)

        column.x = 3; column.y = 11
        column.pushRight()
        assert_equal(column.x, 4)
      end)
    end)
  end)

  test("can be placed in the board", function()
    column.place()
    assert_equal(column[1], board.get(column.x, column.y))
    assert_equal(column[2], board.get(column.x, column.y + 1))
    assert_equal(column[3], board.get(column.x, column.y + 2))
  end)
end)
