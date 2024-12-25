-- #+LATEX_HEADER \usepackage{amsmath}



-- [[file:../org_example/ray_triangle_intersection.org::+BEGIN_SRC lua :tangle ../example/ray_triangle_intersection.lua][No heading:1]]
package.path = package.path .. ";" .. "../src/util/?.lua"
local Vec = require("vec")
local Mat = require("Mat")


local P = Vec.new(0, 0, 0)
local d = Vec.new(1, 1, 1):normlized()

local A = Vec.new(1, 0, 0)
local B = Vec.new(0, 1, 0)
local C = Vec.new(0, 0, 1)
function test_ray_triangle_intersection(P, d, A, B, C)
      local AB = B - A
      local AC = C - A
      local N = Vec.cross3(AB, AC)
      local AB_o = Vec.cross3(N, AB)
      local AC_o = Vec.cross3(N, AC)
      local AB_o = AB_o / (AC:dot(AB_o))
      local AC_o = AC_o / (AB:dot(AC_o))
      local u = N:dot(d)
      
      if(u == 0) then
        print("Ray parall with Plane")
        return false
      end
      
      if math.abs(u) < 1e-15 then
        print("Unstable")
        return false
      end
      
      
      t = ((A-P):dot(N))/u
      
      if t < 0 then
        print("Ray miss plane")
        return false
      end
      
      
      Q = P + t * d
      
      c = (Q - C):dot(AC_o)
      b = (Q - B):dot(AB_o)
      a = 1 - (b + c)
      
      if a < 0 or a > 1 or b < 0 or b > 1 or c < 0 or c > 1 then
        print("Out of triangle,", a, b, c)
        return false
      
      else
        print("Inside triangle,", a, b, c)
        return true
      end
end

print(test_ray_triangle_intersection(P,d,A,B,C))
-- No heading:1 ends here
