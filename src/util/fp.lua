-- Module

-- [[file:../../org/util/fp.org::*Module][Module:1]]
local M = {}
function M.any(t, fn)
   local result = false
   for i,v in ipairs(t) do
      if fn(v, i) then
         result = true
         break
      end
   end

   return result
end
function M.all(t, fn)
   local result = true
   for i,v in ipairs(t) do
      if not fn(v, i) then
         result = false
         break
      end
   end

   return result
end
function M.map(t, fn)
   local result = {}
   for i,v in ipairs(t) do
      result[i] = fn(v, i)
   end

   return result
end
function M.max(t, fn)
   local result 
   for i,v in ipairs(t) do
     if not result then
        result = t[i]
     else
        result = (fn(result, t[i]) and result) or t[i]
     end
   end
   return result
end
function M.min(t, fn)
   local result 
   for i,v in ipairs(t) do
     if not result then
        result = t[i]
     else
        result = (fn(result, t[i]) and t[i]) or result
     end
   end
   return result
end
function M.filter(t, fn)
   local result = {}
   for i,v in ipairs(t) do
      if fn(v, i) then
         table.insert(result, v)
      end
   end

   return result
end
return M
-- Module:1 ends here
