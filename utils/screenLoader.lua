local loader = require 'utils.loader'

local defaults = {
  SCREEN_WIDTH      = 800,
  SCREEN_HEIGHT     = 600,
  SCREEN_FULLSCREEN = false,
  SCREEN_VSYNC      = true,
  SCREEN_FSAA       = 0,
}

-- restore screen global variables.
local function restore()
  print("Loading screen settings...")

  local config = loader.loadTable("screen.dat")

  if not config then
    print(" * Could not load previous settings, using defaults.")
    config = defaults
  else
    print(" * Restored previous screen settings.")
  end

  for k, v in pairs(config) do _G[k] = v end
end

-- store screen global variables.
local function store()
  print("Saving screen settings.")
  local config = {}
  for k, v in pairs(defaults) do config[k] = _G[k] end
  loader.saveTable("screen.dat", config)
end

return {
  restore = restore,
  store = store
}
