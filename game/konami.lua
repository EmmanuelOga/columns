-- txs thelinx http://love2d.org/forums/viewtopic.php?f=5&t=2632
local state = 1
local function konami(key)
  if     state == 1 and key == "up"    then state = state + 1
  elseif state == 2 and key == "up"    then state = state + 1
  elseif state == 3 and key == "down"  then state = state + 1
  elseif state == 4 and key == "down"  then state = state + 1
  elseif state == 5 and key == "left"  then state = state + 1
  elseif state == 6 and key == "right" then state = state + 1
  elseif state == 7 and key == "left"  then state = state + 1
  elseif state == 8 and key == "right" then state = state + 1
  elseif state == 9 and key == "b"     then state = state + 1
  elseif state == 10 and key == "a"    then state = state + 1
  else
    state = 1
  end

  return state == 11
end

return konami
