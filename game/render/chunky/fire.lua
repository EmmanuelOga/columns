local K = require("game.constants")

local hsl = require("utils.hsl")
local dynArray = require("utils.dynArray")
local easing = require('tweener.easing')

local r = math.random
local eh, es, el = easing.linear, easing.outExpo, easing.inQuad

-- render a fire in the chunky display.
local function chunkyFire(chunky)
  local self = {}
  local W, H = chunky.w, chunky.h

  -- we'll store fire intensities in this array
  local fire = dynArray(0, { from=0, to=W + 1 }, { from=0, to=H + 2})

  local function fireUp()
    -- base line of fire is turbulent.
    for i = 1, W do  if r() > 0.95 then fire[i][H + 2] = r() end end

    -- rest of the fire will be interpolated from bottom to top.
    for j = H + 1, 1, -1 do
      for i = 1, W do
        fire[i][j] = (fire[i+1][j-1] +
                    --fire[i  ][j-1] +
                      fire[i-1][j-1] +
                    --fire[i+1][j  ] +
                    --fire[i-1][j  ] +
                      fire[i+1][j+1] +
                      fire[i  ][j+1] +
                      fire[i-1][j+1]) / 5
      end
    end
  end

  local c, d = 0, 0
  local function render()
    for i, j in chunky.coords() do
      d = fire[i][j]
      chunky.put(i, H - j + 1, eh(d, c, 1, 1), es(j, 0.5, 0.5, H), el(j, 0, d, H))
    end
  end

  local function update(dt)
    c = c + dt / 10
    fireUp()
    render()
  end

  return update
end

return chunkyFire
