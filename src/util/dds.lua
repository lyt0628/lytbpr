

-- #+RESULTS:
-- [[file:./asset/dds_layout.png]]


-- 魔數 是文件格式中常用的標識自己文件的一個ID。也就是說，當看到文件有 DDS 魔數存在時。
-- 我們就基本上可以判斷這個文件就是 DDS格式的文件。
-- DDS 文件的魔數是 DWORD 大小的 字符串 "DDS ".注意末尾有一個空格，使得整體大小爲
-- 32比特，即DOWRD（雙字）。

-- [[file:../../org/src/util/dds.org::*DDS 文件的二進制佈局][DDS 文件的二進制佈局:2]]
local luautil = require "luautil"
local Vec = require "vec"
local M = {}
M.__index = M
M.magic = "DDS" .. " "
function M.new(width,height)
   local img = {}
   img.header = {}
   img.header.header_size = 124
   img.header.height = assert(height, "Height of DDS is required")
   img.header.width = assert(width, "Height of DDS is required")
   
   img.height = img.header.height
   img.width = img.header.width
   img.header.flags = 0x1 | 0x2 | 0x4 | 0x1000
   -- 我們的圖像現在只支持不壓縮的圖片
   img.header.flags = img.header.flags | 0x8
   img.header.pitch = width * 4
   img.header.cap = 0x1000
   img.pixels = {}
   local vproto = Vec.new(0,0,0,0)
   
   for i = 1, width*height do
      table.insert(img.pixels, vproto)
   end
   img.header.pixel_format = {}
   img.header.pixel_format.size = 32
   img.header.pixel_format.flags = 0x1 | 0x40
   img.header.pixel_format.fourcc = "BGR1"
   
   img.header.pixel_format.rgb_bit_count = 32
   img.header.pixel_format.bitmask_a = 0xFF000000
   img.header.pixel_format.bitmask_r = 0x00FF0000
   img.header.pixel_format.bitmask_g = 0x0000FF00
   img.header.pixel_format.bitmask_b = 0x000000FF
   setmetatable(img, M)
   return img
end
function M:save(path)
   local f = assert(io.open(path, "wb"))

   f:write(M.magic)

   local header = self.header
   local format = header.pixel_format
   f:write(luautil.to_bint(header.header_size, 4))
 --  print("Header Size: ", header.header_size)


   f:write(luautil.to_bint(header.flags, 4))
   f:write(luautil.to_bint(header.height, 4))
   f:write(luautil.to_bint(header.width, 4))
   f:write(luautil.to_bint(header.pitch, 4))
   f:write(luautil.to_bint(0, 4)) -- Depth
   f:write(luautil.to_bint(0, 4)) -- Mipmap
   f:write(luautil.to_bint(0, 4 * 11)) -- Reversed

   -- pixel_format
   f:write(luautil.to_bint(format.size, 4))
 --  print("Header Size: ", format.size)
   f:write(luautil.to_bint(format.flags, 4))
   f:write(format.fourcc)
   f:write(luautil.to_bint(format.rgb_bit_count, 4))
   f:write(luautil.to_bint(format.bitmask_r, 4))
   f:write(luautil.to_bint(format.bitmask_g, 4))
   f:write(luautil.to_bint(format.bitmask_b, 4))
   f:write(luautil.to_bint(format.bitmask_a, 4))
   -- end pixel_format


   f:write(luautil.to_bint(header.cap, 4)) -- Cap0 
   f:write(luautil.to_bint(0, 4)) -- Cap2 
   f:write(luautil.to_bint(0, 4)) -- Cap3 
   f:write(luautil.to_bint(0, 4)) -- Cap3
   f:write(luautil.to_bint(0, 4)) -- Reversed 

 --  f:write(luautil.to_bint( 4 + 124 + 4 + 4 , 4))
 --  f:write(luautil.to_bint( 4 + 124 + 4 + 4 , 4))

   for _, v in ipairs(self.pixels) do
      f:write(luautil.to_bint(v:b(), 1))
      f:write(luautil.to_bint(v:g(), 1))
      f:write(luautil.to_bint(v:r(), 1))
      f:write(luautil.to_bint(v:a(), 1))
    --  print(v:r(),v:g(),v:b(),v:a())
   end

   f:close()
end
function M:set(row, col, color)
    assert(row > 0 or row <= self.header.height, "Row out of bound!")
    assert(col > 0 or col <= self.header.width, "Col out of bound!")
    self.pixels[col + (row - 1) * self.width] = color
end
function M:get(row, col)
    assert(row > 0 or row <= self.header.height, "Row out of bound!")
    assert(col > 0 or col <= self.header.width, "Col out of bound!")
    return self.pixels[col + (row - 1) * self.header.width] 
end
return M
-- DDS 文件的二進制佈局:2 ends here
