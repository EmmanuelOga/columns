-- particle system

local K = require("game.constants")
local LG = love.graphics

local hsl = require("utils.hsl")
local dynArray = require("utils.dynArray")
local glitter = require("game.render.gems.glitter")

local unit = 16

-- render a particle to an image (through a fb)
local function glitterImage(r, g, b, alpha)
  local fb = LG.newFramebuffer(K.PARTICLES_BASE_SIZE, K.PARTICLES_BASE_SIZE)
  local size = K.PARTICLES_BASE_SIZE

  fb:renderTo(function()
    LG.setBlendMode("alpha")
    for i = 1, 32 do
      LG.setColor(r, g, b, i * 128 / 32 + 64)
      LG.circle("fill", size / 2, size / 2, size / 4 + ( 8 - i / 2 ) * 4, 100)
    end
    LG.push()
    LG.scale(size / unit, size / unit)
    glitter(r, g, b, alpha)
    LG.pop()
  end)
  local image = LG.newImage(fb:getImageData())
  fb = nil
  return image
end

-- Setup a particle system
local function burstPS(x, y, image)
  local p = LG.newParticleSystem(image, K.PARTICLE_BUFFER_PER_CEL)

  p:setEmissionRate( 75 )

  p:setGravity(2000)
  p:setParticleLife(2, 4)
  p:setPosition(x, y)

  p:setOffset(K.PARTICLES_BASE_SIZE / 2, K.PARTICLES_BASE_SIZE / 2) -- rotation offset
  p:setSpin(2, 5)
  p:setSpeed(800, 1000)
  p:setSize(0.25, 0.5)

  p:setDirection(math.pi / 4 * 6) -- radians
  p:setSpread(math.pi / 8)

  p:setRadialAcceleration( 50, 50 )
  p:setTangentialAcceleration( 50, 50 )

  return p
end

-- factory method for the battery of bursts (particle systems)
local function bursts()
  local battery, ps, col = dynArray(), nil, nil

  for i = 1, K.NUM_GEMS do
    col = K.GEM_HSL_COLORS[i]
    local image = glitterImage(hsl(col[1], col[2], col[3] * K.PARTICLES_INTENSITY))

    for x = 1, K.BOARD_WIDTH do
      for y = 1, K.BOARD_HEIGHT do
        ps = burstPS((x - 0.5) * K.GEM_SIZE, (y - 0.5) * K.GEM_SIZE, image)
        ps:stop()
        battery[i][x][y] = { ps = ps, time = 0 } -- if time == 0 the particle system will be stopped.
      end
    end
  end

  local function explode(colorNumber, x, y, time)
    local current = battery[colorNumber][x][y]
    current.time = current.time + time
    if current.time > 0 then current.ps:start() end
  end

  local function render(x0, y0)
    local current
    x0, y0 = x0 or 0, y0 or 0
    for i = 1, K.NUM_GEMS do -- TODO build an iterator.
      for x = 1, K.BOARD_WIDTH do
        for y = 1, K.BOARD_HEIGHT do
          current = battery[i][x][y]
          LG.draw(current.ps, x0, y0)
        end
      end
    end
  end

  local function update(dt)
    local ps, current

    for i = 1, K.NUM_GEMS do
      for x = 1, K.BOARD_WIDTH do
        for y = 1, K.BOARD_HEIGHT do
          current = battery[i][x][y]
          current.ps:update(dt)
          current.time = current.time - dt
          if current.time <= 0 then
            current.time = 0
            current.ps:stop()
          end
        end
      end
    end
  end

  return {
    explode = explode,
    render = render,
    update = update
  }
end

local self = {} -- singleton.

self.initialize = function()
  local b = bursts()
  self.render = b.render
  self.explode = b.explode
  self.update = b.update
end

self.initialize()

return self
