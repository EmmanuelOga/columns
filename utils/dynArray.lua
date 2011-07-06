local dynArray

local dynArrayMeta = {
  __index = function(self, key)
    local new = dynArray()
    self[key] = new
    return new
  end
}

-- dynArray will return an array that will act as a nested array of arrays
-- of as many elements as you want. The first assignment determines the
-- dimension of the array:
--
-- local a = dynArray()
-- a[1][2][3] = 1 --> maximum dimension of a is now 3. if you try to access a fourth dimension, it will fail.
--
-- You can pass an initial value and tables {from=n, to=m} to initialize each array dimenssion:
--
-- local a = dynArray(0, {from=1, to=10}, {from=1, to=10})
-- print(a[1][1]) --> 10. All elements from [1][1] to [10][10] got initialized to 1.
--
dynArray = function(initial, ...)
  local array = setmetatable({}, dynArrayMeta)

  if initial and select('#', ...) > 0 then
    -- metaprogramming at its best... I'm sure there must be a better way.
    local args, init = {...}, "local array, initial = ...\n"
    for i, v in ipairs(args) do
      init = init .. string.rep('  ', i - 1) .. 'for i' .. i .. ' = ' .. v.from .. ', ' .. v.to .. ' do\n'
    end
    init = init .. string.rep('  ', #args) .. 'array'
    for i, v in ipairs(args) do init = init .. '[i' .. i .. ']' end
    init = init .. ' = initial\n'
    for i = #args, 1, -1 do init = init .. string.rep('  ', i - 1) .. 'end\n' end
    assert(loadstring(init), "Error in the dynArray initializer code (check your arguments):\n" .. init)(array, initial)
  end

  return array
end

return dynArray
