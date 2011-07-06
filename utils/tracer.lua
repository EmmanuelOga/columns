--"c": the hook is called every time Lua calls a function;
--"r": the hook is called every time Lua returns from a function;
--"l": the hook is called every time Lua enters a new line of code.
debug.sethook(function(event, ...)
  local info = ""

  for _, v in ipairs{...} do
    info = info .. tostring(v) .. ", "
  end

  local caller = debug.getinfo(3)

  if caller then
    info = info .. caller.what .. " " .. caller.source
    info = info .. "(" .. caller.linedefined .. " > " .. caller.currentline.. " < " .. caller.lastlinedefined .. ")"
    info = info .. " = " .. caller.short_src

    --for k, v in pairs(caller) do
    --  info = info .. k .. "=" .. tostring(v) .. ", "
    --end
  end

  print(info)
end, "crl", 0)
