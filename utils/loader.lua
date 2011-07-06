-- serialize and load a lua table. Uses a sandbox for security.
local LFS = love.filesystem
local sandbox = require('utils.sandbox')
local serialize = require('utils.serialize')

-- serializes table and saves it to the name file.
local function saveTable(name, table)
  LFS.write(name, 'return ' .. serialize(table))
end

-- looks for file name and loads it using a sandbox.
local function loadTable(name)
  return LFS.isFile(name) and sandbox(LFS.read(name))
end

return {
  saveTable = saveTable,
  loadTable = loadTable
}
