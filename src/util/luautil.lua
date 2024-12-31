-- Module

-- [[file:../../org/src/util/luautil.org::*Module][Module:1]]
local M = {}
function M.reverse(tab)
   local result = {}
   for i = #tab, 1, -1 do
       table.insert(result, tab[i])
   end 
   return result
end

function M.remove_hole(tab)
   local result = {}
   local len = #tab
   for i = 1, len do
      if tab[i] then
         table.insert(result, tab[i])
      end
   end
   return result
end
function M.is_number(value)
   return type(value) == "number"
end
function M.is_num(value)
   return M.is_number(value) and math.abs(value) == math.abs(- value)
end
function M.is_little_endian()
   return string.byte(string.pack("I4", 1), 1, 4) == 1
end
function M.is_big_endian()
   return not M.is_little_endian()
end
function M.base_convert(num, toBase)
    local result = ""
    while num > 0 do
        local remainder = math.fmod(num, toBase)
        if remainder >= 10 then
            result = string.char(remainder - 10 + 65) .. result
        else
            result = remainder .. result
        end
        num = math.floor((num - remainder) / toBase)
    end
    return result == "" and "0" or result
end
function M.bint(s)
   local nbyte = assert(string.len(s))
   local result = 0
   if M.is_little_endian() then
      for i = nbyte, 1, -1 do
         result = result << 8
         result = result + string.byte(s,i)
      end
   else
      for i = 1, nbyte do
         result = result >> 8
         result = result + string.byte(s,i)
      end
   end
   return result
end
function M.to_bint(n, nbyte)
   local bytes = {}
   for i = 1, nbyte do
      bytes[i] = string.char(n%256)
      n = math.floor(n/256)
   end
   if M.is_big_endian() then
      bytes = M.reverse(bytes)
   end
   return table.concat(bytes)
end
return M
-- Module:1 ends here
