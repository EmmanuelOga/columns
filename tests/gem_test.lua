local gems = require "columns.gems"
local boards = require "columns.boards"

context("Gem", function()

  context("combinations", function()
    before(function()
      board = boards({ w = 2, h = 1 })
      hole = gems.hole()
      wild = gems.wild()
      fixed = gems.fixed()
      obstacle = gems.obstacle()
      gem_a = gems.normal{ color = 1 }
      gem_b = gems.normal{ color = 1 }
      gem_c = gems.normal{ color = 2 }
    end)

    CHOICES = {
      { 'hole'      , 'hole'      , false  },
      { 'wild'      , 'wild'      , true   },
      { 'fixed'     , 'fixed'     , false  },
      { 'obstacle'  , 'obstacle'  , false  },
      { 'gem_a'   , 'gem_a'   , true   },
      { 'gem_b'   , 'gem_b'   , true   },
      { 'gem_c'   , 'gem_c'   , true   },
      { 'hole'      , 'wild'      , false  },
      { 'hole'      , 'fixed'     , false  },
      { 'hole'      , 'obstacle'  , false  },
      { 'hole'      , 'gem_a'   , false  },
      { 'hole'      , 'gem_b'   , false  },
      { 'hole'      , 'gem_c'   , false  },
      -- Wildcards get their own tests.
      --{ 'wild'      , 'fixed'     , false  },
      --{ 'wild'      , 'obstacle'  , false  },
      --{ 'wild'      , 'gem_a'   , true   },
      --{ 'wild'      , 'gem_b'   , true   },
      --{ 'wild'      , 'gem_c'   , true   },
      { 'fixed'     , 'obstacle'  , false  },
      { 'fixed'     , 'gem_a'   , false  },
      { 'fixed'     , 'gem_b'   , false  },
      { 'fixed'     , 'gem_c'   , false  },
      { 'obstacle'  , 'gem_a'   , false  },
      { 'obstacle'  , 'gem_b'   , false  },
      { 'obstacle'  , 'gem_c'   , false  },
      { 'gem_a'   , 'gem_b'   , true   },
      { 'gem_a'   , 'gem_c'   , false  },
      { 'gem_b'   , 'gem_c'   , false  },
    }

    for _, combination in ipairs(CHOICES) do
      test("compares " .. combination[1] .. " with " .. combination[2], function()
        local env = getfenv()
        local a = env[combination[1]]
        local b = env[combination[2]]

        if combination[3] then
          board.set(1, 1, a); board.set(2, 1, b)
          assert_true(gems.isMatch(board, {{x=1, y=1}, {x=2, y=1}}, 1))

          board.set(1, 1, b); board.set(2, 1, a)
          assert_true(gems.isMatch(board, {{x=1, y=1}, {x=2, y=1}}, 1))
        else
          board.set(1, 1, a); board.set(2, 1, b)
          assert_false(not not gems.isMatch(board, {{x=1, y=1}, {x=2, y=1}}, 1))

          board.set(1, 1, b); board.set(2, 1, a)
          assert_false(not not gems.isMatch(board, {{x=1, y=1}, {x=2, y=1}}, 1))
        end
      end)
    end
  end)

  context("wildcards", function()
    before(function()
      coords = {{x=1, y=1}, {x=2, y=1}, {x=3, y=1}}
      board = boards({ w = 4, h = 1 })
      hole = gems.hole()
      wild = gems.wild()
      fixed = gems.fixed()
      obstacle = gems.obstacle()
      gem_a = gems.normal{ color = 1 }
      gem_b = gems.normal{ color = 2 }
    end)

    test("WAA wildcards matches", function()
      board.set(1, 1, wild); board.set(2, 1, gem_a); board.set(3, 1, gem_a)
      assert_true(not not gems.isMatch(board, coords, 1))
      assert_true(not not gems.isMatch(board, coords, 2))
    end)

    test("AWA wildcards matches", function()
      board.set(1, 1, gem_a); board.set(2, 1, wild); board.set(3, 1, gem_a)
      assert_true(not not gems.isMatch(board, coords, 1))
      assert_true(not not gems.isMatch(board, coords, 2))
    end)

    test("AAW wildcards matches", function()
      board.set(1, 1, gem_a); board.set(2, 1, gem_a); board.set(3, 1, wild)
      assert_true(not not gems.isMatch(board, coords, 1))
      assert_true(not not gems.isMatch(board, coords, 2))
    end)

    test("WAB wildcards does not match", function()
      board.set(1, 1, wild); board.set(2, 1, gem_a); board.set(3, 1, gem_b)
      assert_false(not not gems.isMatch(board, coords, 1))
      assert_false(not not gems.isMatch(board, coords, 2))
    end)

    test("AWB wildcards does not match", function()
      board.set(1, 1, gem_a); board.set(2, 1, wild); board.set(3, 1, gem_b)
      assert_false(not not gems.isMatch(board, coords, 1))
      assert_false(not not gems.isMatch(board, coords, 2))
    end)

    test("BAW wildcards does not match", function()
      board.set(1, 1, gem_b); board.set(2, 1, gem_a); board.set(3, 1, wild)
      assert_false(not not gems.isMatch(board, coords, 1))
      assert_false(not not gems.isMatch(board, coords, 2))
    end)

    test("ABW wildcards does not match", function()
      board.set(1, 1, gem_a); board.set(2, 1, gem_b); board.set(3, 1, wild)
      assert_false(not not gems.isMatch(board, coords, 1))
      assert_false(not not gems.isMatch(board, coords, 2))
    end)

    test("WAW wildcards matches", function()
      board.set(1, 1, wild); board.set(2, 1, gem_a); board.set(3, 1, wild)
      assert_true(gems.isMatch(board, coords, 1))
      assert_true(gems.isMatch(board, coords, 2))
    end)

    test("AAWB wildcards matches only first 3", function()
      board.set(1, 1, gem_a); board.set(2, 1, gem_a); board.set(3, 1, wild); board.set(4, 1, gem_a)
      assert_true(gems.isMatch(board, coords, 1))
      assert_true(gems.isMatch(board, coords, 2))
      assert_false(not not gems.isMatch(board, coords, 3))
    end)

  end)
end)
