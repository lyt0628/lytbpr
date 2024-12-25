-- Module

-- [[file:../../org/util/vec.org::*Module][Module:1]]
local M = {}
M.classid = "Vec"

function M.new(...) 
   if not ...  then
      error("[Vec.new] vector cannot be empty!")
   end
   local elems = {...}
   local v= {elems = elems}
   setmetatable(v, M)
   return v
end
function M:get(idx)
  if not idx then
     error("[Vec:get] index of element is required as paramter!")
  end
  if idx > self:size() then
     error("[Vec:get] index out of bound!")
  end
  return self.elems[idx]
end
function M:with(idx, value)
  if not idx then
     error("[Vec:get] index of element is required as paramter!")
  end
  if idx > self:size() then
     error("[Vec:get] index out of bound!")
  end

  local result = self:clone()
  result.elems[idx] = value

  return result
end
function M:size()
  return #(self.elems)
end
function M:add(other)
  if(self:size() ~= other:size()) then
    error("[vec:add] length of component of vec must equal!")
  end

  local result = {}
  for i = 1, self:size() do
    result[i] = self:get(i) + other:get(i)
  end
  return M.new(table.unpack(result))
end
function M:sub(other)
  if(self:size() ~= other:size()) then
    error("[vec:sub] length of component of vec must equal!")
  end

  local result = {}
  for i = 1, self:size() do
    result[i] = self[i] - other[i] 
  end

  return M.new(table.unpack(result))
end
function M:mul(other)
  if(self:size() ~= other:size()) then
    error("[vec:mul] length of component of vec must equal!")
  end

  local result = {}
  for i = 1, self:size() do
    result[i] = self[i] * other[i] 
  end
  return M.new(table.unpack(result))
end
function M:div(other)
  if(self:size() ~= other:size()) then
    error("[vec:div] length of component of vec must equal!")
  end
  

  local result = {}
  for i = 1, self:size() do
    result[i] = self[i] / other[i] 
  end

  return M.new(table.unpack(result))
end
function M:scale(scalar)
  local result = {}
  for i = 1, self:size() do
     result[i]= self.elems[i] * scalar
  end
  return M.new(table.unpack(result))
end
function M:normlized()
  local result = {}
  local len = #self
  for i = 1, self:size() do
     result[i]= self.elems[i] / len
  end
  return M.new(table.unpack(result))
end
 function M:dot(other)
  if(self:size() ~= other:size()) then
    error("[vec:dot] length of component of vec must equal!")
  end
  
  local sum = 0
  for i = 1, self:size() do
     sum = sum + self[i] * other[i]
  end
  return sum
end   
function M:clone()
   local result = {}
   table.move(self.elems, 1, self:size(), 1, result)
   return M.new(table.unpack(result))
end
function M:slice(startIdx, endIdx)
   local elems = {}
   table.move(self.elems, startIdx, endIdx, 1, elems)
   return M.new(table.unpack(elems))
end 
function M:concat(other)
   local elems = {}
   table.move(self.elems, 1, self:size(), 1, elems)
   table.move(other.elems, 1, other:size(), self:size() + 1, elems)
   return M.new(table.unpack(elems))
end 
-- Used for location
function M:x() return self[1] end
function M:y() return self[2] end
function M:z() return self[3] end
function M:w() return self[4] end


function M:xy() return M.new(self:x(), self:y()) end
function M:yz() return M.new(self:y(), self:z()) end
function M:zw() return M.new(self:z(), self:w()) end

function M:xyz() return M.new(self:x(), self:y(), self:z()) end
-- Used for color
function M:r() return self[1] end
function M:g() return self[2] end
function M:b() return self[3] end
function M:a() return self[4] end

function M:rgb() return Vec.new(self:r(), self:g(), self:b()) end
-- Used for texture
function M:s() return self[1] end
function M:t() return self[2] end
function M:p() return self[3] end
function M:q() return self[4] end

function M:st() return M.new(self:s(), self:t()) end
function M:pq() return M.new(self:p(), self:q()) end
 function M.cross3(one, other)
  local x = one:y() * other:z() - one:z() * other:y()
  local y = one:z() * other:x() - one:x() * other:z()
  local z = one:x() * other:y() - one:y() * other:x()

  return M.new(x, y, z)
end   
function M.__index(t, key)
   local result
   if type(key) == "number" then
     result = t:get(key)
   elseif rawget(t, key) then
      result = rawget(t, key)
   else
      result = rawget(M, key)
   end
   return result
end
function M.__concat(lhv, rhv)
   return lhv:concat(rhv)
end
function M.__len(v)
  local sum = 0
  for i = 1, v:size() do
     sum = sum + v[i]^2
  end
  return math.sqrt(sum)
end
function M.__add(lhv, rhv)
  return lhv:add(rhv)
end
function M.__sub(lhv,rhv)
  return lhv:sub(rhv)
end
function M.__div(lhv,rhv)
   local result
   if type(rhv) == "number" then
      if rhv == 0 then error("divided by zero") end
      result = lhv:scale(1/rhv)
   else
      result = lhv:div(rhv)
   end
   return result
end
function M.__mul(lhv, rhv)
  local result
  if type(lhv) == "number" then
     return rhv:scale(lhv)
  elseif type(rhv) == "number" then
     return lhv:scale(rhv)
  end
  result = lhv:mul(rhv)
  return result
end
function M:to_str()
  local s = "[ "
  for i = 1, self:size() do
     s = s .. self:get(i) .. ", " 
  end
  s = s .. "]"
  return s
end
return M
-- Module:1 ends here
