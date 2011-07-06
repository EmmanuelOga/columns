-- http://lua-users.org/wiki/SandBoxes

-- This environment is empty because it will be used to load
-- settings, which do not need to access the lua runtime in any way,
-- only the basic language primitives.
local env = {}

-- Example:
-- run [[ functionf(x) return x^2 end; t={2}; t[1] = f(t[1]) ]]
local function run(untrusted_code)
  local untrusted_function, message = loadstring(untrusted_code)
  if not untrusted_function then return nil, message end
  setfenv(untrusted_function, env)
  local results = {pcall(untrusted_function)}
  if results[1] then
    return select(2, unpack(results))
  else
    print("Error running sandboxed code:")
    print(results[2])
    return false
  end
end

return run
