-- Module

-- [[file:../../org/util/ray.org::*Module][Module:1]]
local luautil = require("luautil")
local fp = require("fp")
local M = {}
M.classid = "Vec"
function M.new(origin, direction) 
   local ray = {
      origin = origin,
      direction = direction
   }

   setmetatable(ray, M)

   return ray
end
function M.__call(self, t) 
   return self.origin + t * self.direction
end
return M
-- Module:1 ends here
