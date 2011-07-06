local dynArray = require('utils.dynArray')

-- this is just an array of width x height elements
-- with some useful functions like smoothing all values,
-- puting with bounds check, multiplying all values,
-- and an iterator to go through all coordinates.
local function buffer(w, h)
  local self = dynArray(0, {from=0, to=w}, {from=0, to=h})

  local function coords()
    local x, y = 0, 1
    return function()
      while not(x == w and y == h) do
        x = x + 1
        if x > w then x, y = 1, y + 1 end
        return x, y
      end
    end
  end

  function self.put(val, x, y, xw, xh)
    for i = x, x + (xw or 1) - 1 do
      for j = y, y + (xh or 1) - 1 do
        if i > 0 and i <= w and j > 0 and j <= h then
          self[i][j] = val
        end
      end
    end
  end

  function self.get(x, y)
    return self[x][y]
  end

  function self.smoothTo(other)
    -- sides
    for i = 2, w - 1 do
      other[i][1] = (self[i-1][1] + self[i+1][1] + self[i-1][  2] + self[i][  2] + self[i+1][  2]) / 5
      other[i][h] = (self[i-1][h] + self[i+1][h] + self[i-1][h-1] + self[i][h-1] + self[i+1][h-1]) / 5
    end

    for j = 2, h - 1 do
      other[1][j] = (self[1][j-1] + self[1][j+1] + self[2  ][j-1] + self[2  ][j] + self[2  ][j+1]) / 5
      other[w][j] = (self[w][j-1] + self[w][j+1] + self[w-1][j-1] + self[w-1][j] + self[w-1][j+1]) / 5
    end

    -- corners
    other[1][1] = (self[2][1]   + self[1][2]     + self[2][2]) / 3
    other[w][1] = (self[w-1][1] + self[w-1][2]   + self[w][2]) / 3
    other[1][h] = (self[2][h]   + self[1][h-1]   + self[2][h-1]) / 3
    other[w][h] = (self[w-1][h] + self[w-1][h-1] + self[w][h-1]) / 3

    -- middle
    for i = 2, w - 1 do
      for j = 2, h - 1 do
        other[i][j] = (self[i+1][j-1] +
                       self[i  ][j-1] +
                       self[i-1][j-1] +
                       self[i+1][j  ] +
                       self[i-1][j  ] +
                       self[i+1][j+1] +
                       self[i  ][j+1] +
                       self[i-1][j+1]) / 8
      end
    end
    return other, self
  end

  function self.multiply(d)
    for x, y in coords() do self[x][y] = self[x][y] * d end
  end

  function self.clear(val)
    for x, y in coords() do self[x][y] = val end
  end

  self.w = w
  self.h = h
  self.coords = coords

  return self
end

return buffer
