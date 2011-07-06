-- simple serializer adapted from the one on the pil book, for our humble needs.
-- converts a table to a storable string.
local function serialize(o)
  local str = ""

  local append = function(...)
    for _, val in ipairs{...} do str = str .. tostring(val) end
  end

  if type(o) == "number" or type(o) == "boolean" then
    append(o)

  elseif type(o) == "string" then
    append(string.format("%q", o))

  elseif type(o) == "table" then

    append("{\n")
    for k, v in pairs(o) do
      append(" ", k, " = ")
      append(serialize(v))
      append(",\n")
    end
    append("}\n")

  else
    error("cannot serialize a " .. type(o))
  end

  return str
end

return serialize
