-- Module

-- [[file:../../org/util/mat.org::*Module][Module:1]]
local luautil = require "luautil"
local Vec = require "Vec"

local M = {}
M.classid = "Mat"
function M.new(rows) 
   if not rows or rows[1] == nil or rows[1][1] == nil then
      error("Mat cannot be empty!")
   end
   local nelems = #(rows[1])
   for i = 2, #(rows) do
      if #(rows[i]) ~= nelems then
         error("Size of rows should be same!")
      end
   end
   local vecs = {}
   local nrows = #(rows)
   local ncols = #(rows[1])
   for c = 1, ncols do
     local col = {}
     for r = 1, nrows do
       col[r] = rows[r][c]
     end
     vecs[c] = Vec.new(table.unpack(col))
   end
   local mat = {vecs = vecs}
   setmetatable(mat, M)
   return mat
end
function M.from_vecs(vecs)
   if not vecs or vecs[1] == nil then
      error("Mat cannot be empty!")
   end
   
   local nvecs = #(vecs)
   local nds = vecs[1]:size()
   for i = 1, nvecs do
      if vecs[i]:size() ~= nds then
         error("All vecs must hold same amount of elems!")
      end
   end
  local mat = {vecs = vecs}
  setmetatable(mat, M)
  return mat
end
function M.from_elems(elems, nrow)
  if(#(elems) % nrow ~= 0) then
    error("Elems must be divided just")
  end
  local rows = {}
  local ncol = #(elems) / nrow;
  for r = 1, nrow do
    local row = {}
    for c = 1, ncol do
        row[c] = elems[c + (r - 1) * ncol]
    end
    rows[r] = row
  end
  return M.new(rows)
end
function M:get(row,col)
   if (not row or not col) then
      error("position row and col cannot be empty!")
   end
   if (row > self:rows() or col > self:cols()) then
    error("target position cannot out of bound of matrix")
   end
   return self.vecs[col]:get(row)
end
function M:with(row, col, value)
   if (not row or not col) then
      error("position row and col cannot be empty!")
   end
   if (row > self:rows() or col > self:cols()) then
    error("target position cannot out of bound of matrix")
   end
   local result = self:clone()
   result.vecs[col].elems[row] = value
   return result
end
function M:with_col(col, value)
   local result = self:clone()
   result.vecs[col] = value
   return result
end
function M:with_row(row, value)
   if row > self:rows() then
      error("[Mat:with_row] row cannot out of bound!")
   end
   local result = self:clone()
   for c = 1, self:cols() do
      result.vecs[c].elems[row] = value:get(c)
   end
   return result
end
function M:cols()
  return #(self.vecs)
end
function M:rows()
  return self.vecs[1]:size()
end
function M:col(c)
  return self.vecs[c]:clone()
end
function M:row(r)
   local elems = {}

   for i = 1, self:cols() do
     elems[i] = self:get(r,i)
   end
   return Vec.new(table.unpack(elems))
end
function M:add(other)
  if self:cols() ~= other:cols() or self:rows() ~= other:rows() then
    error("The shape of Mat must be same!")
  end
  local vecs = {}
  for i = 1, self:cols() do
      vecs[i] = self.vecs[i]:add(other.vecs[i])
  end
  return M.from_vecs(vecs)
end
function M:sub(other)
  if self:cols() ~= other:cols() or self:rows() ~= other:rows() then
    error("The shape of Mat must be same!")
  end
  local vecs = {}
  for i = 1, self:cols()  do
      vecs[i] = self.vecs[i]:sub(other.vecs[i])
  end
  return M.from_vecs(vecs)
end
function M:clone()
  local vecs = {}
  for i,v in ipairs(self.vecs) do
    table.insert(vecs, v:clone())
  end
  return M.from_vecs(vecs)
end
function M:scale(scalar)
  local vecs = {}
  for i = 1, self:cols() do
     vecs[i] = self:col(i):scale(scalar)
  end
  return M.from_vecs(vecs)
end
function M:T()
  local elems = {}
  for c = 1, self:cols() do
   local col_elems = self:col(c).elems
   table.move(col_elems, 1, #col_elems, #elems +1, elems)
  end
  return M.from_elems(elems, self:cols())
end
function M:mul(other)
  if(other:cols() ~= self:rows()) then
    error("Mat multyply need amount of cols of left hand value(as param) eq to rows of right hand value!")
  end
  local nrow = other:rows()
  local ncol = self:cols()
  local elems = {}

  for r = 1, nrow do
     for c = 1, ncol do
       elems[c + (r - 1) * ncol] = other:row(r):dot(self:col(c))
     end
  end

  return Mat.from_elems(elems, nrow)
end
function M:mul_with_vec(vec)
   local mat = Mat.from_vecs({vec})
   mat = mat:mul(self)
   return mat:col(1)
end
function M:slice(r1, c1, r2, c2)
  local vecs = {}
  for i = c1, c2 do
    table.insert(vecs, self:col(i):clone())
  end

  for i,v in ipairs(vecs) do
     vecs[i] = v:slice(r1, r2)
  end
  return Mat.from_vecs(vecs)
end
function M:augmented(vecs)
   if (not vecs or not vecs[1]) then  error("vecs should not be empty!") end
   for i = 1, #(vecs) do
     if (vecs[i]:size() ~= self:rows()) then error("amount of row of Vector should be same as Matrix") end
   end
   local result = self:clone()
   table.move(vecs, 1, #(vecs), result:cols() + 1, result.vecs)
   return result
end
function M:swap_row(r1, r2)
  local result = self:with_row(r1,self:row(r2))
  result = result:with_row(r2,self:row(r1))
  return result
end
function M:scale_row(r, scalar)
  local result = self:clone()
  local row = result:row(r) * scalar

  return result:with_row(r,row)
end
function M:add_to_row(r,vec)
   local result = self:clone()
   local row = result:row(r):add(vec)

  return result:with_row(r,row)
end
function M:identity()
   if(self:rows() ~= self:cols()) then
     error("determinant only meaningful for square matrix!")
   end
   local dimension = self:cols()
   elems = {}
   for r = 1, dimension do
       for c = 1, dimension do
           elems[c + (r-1)*dimension] = ((r == c) and 1) or 0
       end
   end
   return Mat.from_elems(elems, dimension)
end
function M:cofactor(row, col)
   if(self:rows() ~= self:cols()) then
     error("determinant only meaningful for square matrix!")
   end
   if (not row or not col) then
      error("position row and col cannot be empty!")
   end
   if ( row > self:rows() or col > self:cols()) then
    error("Out of Bound of Matrix")
   end
   local result = self:clone()

   result.vecs[col] = nil
   result.vecs = luautil.remove_hole(result.vecs)

   for i = 1, result:cols() do
      result.vecs[i].elems[row] = nil
      result.vecs[i].elems = luautil.remove_hole(result.vecs[i].elems)
   end
   return result
end
function M:algebraic_cofactor(row, col)
   local result = self:cofactor(row,col)
   local r = result:row(1) * math.pow(-1, row + col)
   return result:with_row(1, r)
end
function M:det()
   if(self:rows() ~= self:cols()) then
     error("determinant only meaningful for square matrix!")
   end
   local result = 0
   if(self:rows() == 1) then
      result =self[1][1]
   elseif (self:rows() == 2) then
      result = self[1][1] * self[2][2] - self[1][2] *  self[2][1]
   else
      for c = 1, self:cols() do
        local a = self:algebraic_cofactor(1,c)
        local elem = self[1][c]
        a = a:with_row(1, a:row(1) * elem)
        result = result +  a:det()
      end
   end
   return result
end
function M:reduced()
   local mat = self:clone()
   local times = math.min(self:rows(),self:cols())

   local r = 1
   for c = 1, times do
        if mat[r][c] == 0 then
           local row = 0 -- Init with 0, that is not found
           for j = r + 1, mat:rows() do 
              if(mat[j][c] ~= 0) then
                  row = j
                  break
              end
           end
           if(row == 0) then -- Not Found
              goto continue
           else
              mat = mat:swap_row(r, row)
       
           end
       --[[
          print(mat[1][1],mat[1][2], mat[1][3])
          print(mat[2][1],mat[2][2], mat[2][3])
          print(mat[3][1],mat[3][2], mat[3][3])
          print("---------------------------")
        --]]
        end
       -- When Matrix is not full rank, maybe no head elem, mat[r][c] will be zero in last row
       if(mat[r][c] ~= 1 and mat[r][c] ~= 0) then
          mat = mat:scale_row(r, 1 / mat:get(r, c))
       end
       for j = 1, self:rows() do
         if(j ~= r and mat[j][c] ~=0) then
          local v = mat:row(r)
          v = v:scale(-1 * mat:get(j, c))
          mat = mat:add_to_row(j ,v)
         end
       end

       r = r + 1 -- Increase current row to put head elem
       ::continue::
   end
   return mat
end
function M:simplified()
   local mat = self:clone()
   local times = math.min(self:rows(),self:cols())

   local r = 1
   for c = 1, times do
        if mat[r][c] == 0 then
           local row = 0 -- Init with 0, that is not found
           for j = r + 1, mat:rows() do 
              if(mat[j][c] ~= 0) then
                  row = j
                  break
              end
           end
           if(row == 0) then -- Not Found
              goto continue
           else
              mat = mat:swap_row(r, row)
       
           end
       --[[
          print(mat[1][1],mat[1][2], mat[1][3])
          print(mat[2][1],mat[2][2], mat[2][3])
          print(mat[3][1],mat[3][2], mat[3][3])
          print("---------------------------")
        --]]
        end
       -- When Matrix is not full rank, maybe no head elem, mat[r][c] will be zero in last row
       if(mat[r][c] ~= 1 and mat[r][c] ~= 0) then
          mat = mat:scale_row(r, 1 / mat:get(r, c))
       end
       for j = r + 1, self:rows() do
         if(mat[j][c] ~=0) then
          local v = mat:row(r)
          v = v:scale(-1 * mat:get(j, c))
          mat = mat:add_to_row(j ,v)
         end
       end

       r = r + 1 -- Increase current row to put head elem
       ::continue::
--[[
  print(mat[1][1],mat[1][2], mat[1][3])
  print(mat[2][1],mat[2][2], mat[2][3])
  print(mat[3][1],mat[3][2], mat[3][3])
  print("---------------------------")
--]]

   end
   return mat
end
function M:rank()
   local mat = self:T()
   mat = mat:simplified()

   local rank = mat:rows()
   for r = mat:rows(), 1, -1 do
      for c = mat:cols(), 1, -1 do
         if (mat[r][c] ~= 0 ) then goto END end
      end
      rank = rank - 1
   end
   ::END::
   return rank
end
function M:inverse()
   if(self:rows() ~= self:cols()) then
     error("determinant only meaningful for square matrix!")
   end
   if(self:det() == 0) then
      error("Matrix is singular, haing no inversed matrix!")
   end
   local mat = self .. self:identity()
   mat = mat:simplified()

   local dimension = self:cols()
   return mat:slice(1, dimension + 1, dimension, 2*dimension)
end
function M:ortho()
   -- We Cound by row
   local mat = self:T()
   mat = mat:simplified()
   local result = {}

   local rank = self:rank()
   if (rank == mat:cols()) then
      error("[Mat#ortho()] Full rank matrix cannot find ortho")
   end
   local freedom = self:cols() - rank + (self:rows() - self:cols()) -- Reserve for extra freedom for over-space
   while freedom > 0 do
      table.insert(result, 1)
      freedom = freedom - 1
   end
   for r = rank, 1, -1 do
      local value = 0
      local hit_head = false
      for c = 1, mat:cols() do
          if(hit_head) then
              value = value - result[mat:cols() - c + 1] * mat[r][c]
          end
          if (not hit_head and mat[r][c] ~=0) then
             hit_head = true
          end
      end
      table.insert(result, value)
   end 

   result = luautil.reverse(result)
   return Vec.new(table.unpack(result))
end
function M.__mul(lhv, rhv)
   if(lhv.classid == "Mat" and rhv.classid == "Mat") then
      return rhv:mul(lhv)
   elseif (lhv.classid == "Mat" and rhv.classid == "Vec") then
      return lhv:mul_with_vec(rhv)
   end
   error("Invalid Operation")
end
function M.__concat(lhv, rhv)
   if(lhv.classid == "Mat" and rhv.classid == "Mat") then
      return lhv:augmented(rhv.vecs)
   elseif (lhv.classid == "Mat" and rhv.classid == "Vec") then
      return lhv:augmented({rhv})
   end
   error("Invalid Operation")
end
function M:__pow(power)
   if(self:rows() ~= self:cols()) then
     error("determinant only meaningful for square matrix!")
   end
   local cnt = 1
   local unit
   local result
   if(power > 0) then
      unit = self:clone()
      result = unit
      while (cnt < power) do
         result = result:mul(unit)
         cnt = cnt + 1
      end
   elseif (power < 0 ) then
      unit = self:inverse()
      result = unit
      power = math.abs(power)
      while cnt < power do
         result = result:mul(unit)
         cnt = cnt + 1
      end

   else
      error("Power cannot be zero")
   end

   return result
end
function M.__index(t, key)
   if type(key) == "number" then
      -- If not found, nil will be returned.
      return t:row(key)
   elseif rawget(t, key) then
      return rawget(t, key)
   else
      return rawget(M, key)
   end

end
function M.__add(lhv, rhv)
  return lhv:add(rhv)
end
function M:to_str()
   local s = "[ "
   for r = 1, self:rows() do
       s = s .. "\n" .. self:row(r):to_str()
   end
   s = s .. "\n ]"
   return s
end
return M
-- Module:1 ends here
