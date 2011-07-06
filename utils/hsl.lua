-- http://www.easyrgb.com/index.php?X=MATH&H=19#text19

local function hue_to_rgb(v1, v2, vh)
  if vh < 0 then vh = vh + 1 end
  if vh > 1 then vh = vh - 1 end

  if 6 * vh < 1 then return v1 + ( v2 - v1 ) * 6 * vh end
  if 2 * vh < 1 then return v2 end
  if 3 * vh < 2 then return v1 + ( v2 - v1 ) * ((2/3) - vh) * 6 end

  return v1
end

-- input: 0..1, 0..1, 0..1, 0..1
-- output: 0..255, 0..255, 0..255, 0..255
local function hsl(h, s, l, alpha)
  h = h % 1

  if s == 0 then -- HSL from 0 to 1
    l = l * 255
    return l, l, l, 255 * (alpha or 1)
  else
     if l < 0.5 then
       v2 = l * (1 + s)
     else
       v2 = (l + s) - (s * l)
     end

     v1 = 2 * l - v2

     return 255 * hue_to_rgb(v1, v2, h + (1 / 3)),
            255 * hue_to_rgb(v1, v2, h),
            255 * hue_to_rgb(v1, v2, h - (1 / 3)),
            255 * (alpha or 1)
  end
end

return hsl
