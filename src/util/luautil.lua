-- Module

-- [[file:../../org/util/luautil.org::*Module][Module:1]]
M = {}
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

return M
-- Module:1 ends here