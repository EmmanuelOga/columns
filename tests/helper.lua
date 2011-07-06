SCREEN_WIDTH, SCREEN_HEIGHT = 800, 600

local fakeFont = function(name, size)
  return {
    getWidth = function(self, text) return #text * size end,
    getHeight = function(self, text) return size end,
  }
end

-- define fake love functions
love = {
  graphics = {
    getWidth = function() return SCREEN_WIDTH end,
    getHeight = function() return SCREEN_HEIGHT end,
    newFont = fakeFont,
  },
  audio = {
    setVolume = function() end
  }
}
