local dynArray = require "utils.dynArray"

context("dynArray", function()
  before(function()
    darr = dynArray()
  end)

  test("any not defined index returns an array", function()
    assert_equal(type(darr[1]), "table")
    assert_equal(type(darr[2]), "table")
  end)

  test("can assign properties in any level", function()
    darr[1] = "hola"
    darr[2][3][4] = "mundo"

    assert_equal(darr[1], "hola")
    assert_equal(darr[2][3][4], "mundo")
  end)

  test("can assign properties in any level", function()
    kind1 = {}
    kind2 = {}

    for x = 1, 3 do
      for y = 1, 3 do
        for z = 1, 3 do
          darr[kind1][x][y][z] = "1"
          darr[kind2][x][y][z] = "2"
        end
      end
    end

    for x = 1, 3 do
      for y = 1, 3 do
        for z = 1, 3 do
          assert_equal("1", darr[kind1][x][y][z])
          assert_equal("2", darr[kind2][x][y][z])
        end
      end
    end
  end)

  test("can initialize the array", function()
    darr = dynArray(42, {from=0, to=10}, {from=0, to=10})

    for i = 0, 10 do
      for j = 0, 10 do
        assert_equal(darr[i][j], 42)
      end
    end
  end)
end)
