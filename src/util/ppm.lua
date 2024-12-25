-- Module Definition
-- Let us use Lua Module to define the Vec type. 

-- [[file:../../org/util/ppm.org::*Module Definition][Module Definition:1]]
local Vec = require("vec")
PPM = {}
PPM.__index = PPM
PPM.magic = 'P3'

function PPM.new(w, h)
  if not w or not h then error("Width and Height of PPM must given.") end

  local img = {}
  img.width = w 
  img.height = h
  img.pixels = {} -- Array to store pixel, all elems are Color type
  for row = 1, img.width do
     for col = 1, img.height do
        img.pixels[col + (row - 1) * img.width] = Vec.new(0, 0, 0)
     end
  end

  img.max_value = 255 -- 8 channel Color with RGB

  setmetatable(img, PPM)
  return img
end

function PPM:save(path)
  local f = io.open(path, 'w')
    f:write(PPM.magic .. '\n')
    f:write(self.width .. '\n')
    f:write(self.height .. '\n')
    f:write(self.max_value .. '\n')
    for i = 1, #(self.pixels) do
      local p = self.pixels[i]
      local r = math.floor(p:r())  
      local g = math.floor(p:g())  
      local b = math.floor(p:b())
    
      r = ((r > self.max_value) and 255) or r
      g = ((g > self.max_value) and 255) or g
      b = ((b > self.max_value) and 255) or b
    
      f:write( r .. " " .. g .. " " .. b  .. '\n')
    end
  f:close()
end
function PPM:set(row, col, color)
    if row > self.height or col > self.width then error("Out of bounds of PPM image. ") end
    self.pixels[col + (row - 1) * self.width] = color
end
function PPM:get(row, col)
    if row > self.height or col > self.width then error("Out of bounds of PPM image. ") end
    return self.pixels[col + (row - 1) * self.width] 
end
return PPM
-- Module Definition:1 ends here
