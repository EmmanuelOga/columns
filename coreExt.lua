math.phi = ( 1 + math.sqrt(5) ) / 2 -- http://en.wikipedia.org/wiki/Golden_ratio

--http://stackoverflow.com/questions/147515/least-common-multiple-for-3-or-more-numbers

function math.gcd(a, b) -- euclidean algorithm
  while b ~= 0 do a, b = b, a % b end
  return a
end

-- least common multiplier of many numbers. lcm(a,b,c) = lcm(a, lcm(b, c))
function math.lcm(...)
  assert(select("#", ...) > 1, "At least two numbers needed")

  local function lcm(a, b) return(a * b / math.gcd(a, b)) end

  if select("#", ...) == 2 then
    return lcm(...)
  else
    return lcm(..., math.lcm(select(2, ...)))
  end
end

function math.log2(n)
  return math.log(n) / math.log(2)
end
