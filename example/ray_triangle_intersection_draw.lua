-- Draw Image With Ray-Triangle Intersection

-- [[file:org/ray_triangle_intersection.org::*Draw Image With Ray-Triangle Intersection][Draw Image With Ray-Triangle Intersection:1]]
package.path = package.path .. ";" .. "../src/util/?.lua"
local Vec = require("vec")
local Mat = require("mat")
local PPM = require("ppm")

function test_ray_triangle_intersection(P, d, A, B, C)
      local AB = B - A
      local AC = C - A
      local N = Vec.cross3(AB, AC)
      local AB_o = Vec.cross3(N, AB)
      local AC_o = Vec.cross3(N, AC)
      AB_o = AB_o / (AC:dot(AB_o))
      AC_o = AC_o / (AB:dot(AC_o))
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
      local Q = P + t * d
      
      local c = (Q - C):dot(AC_o)
      local b = (Q - B):dot(AB_o)
      local a = 1 - (b + c)
      
      if a < 0 or a > 1 or b < 0 or b > 1 or c < 0 or c > 1 then
        print("Out of triangle,", a, b, c)
        return false
      
      else
        print("Inside triangle,", a, b, c)
        return true
      end
end

local img = PPM.new(64, 64)

local P = Vec.new(-1, 0, 0)
local A = Vec.new(1, -32, 31)
local B = Vec.new(6, 1, 5)
local C = Vec.new(1, 24, 20)

directions = {}
for z = -32, 31 do
  for y = -32, 31 do
     table.insert(directions, Vec.new(1, y, z))
  end
end
for r = 1, 64 do
  for c = 1, 64 do
     local inside = test_ray_triangle_intersection(P, directions[r + (c-1)*64 ],A,B,C)
     if (inside) then
        img:set(r,c, Vec.new(255,0,0))
     end
  end
end

img:save("triangle.ppm")
-- Draw Image With Ray-Triangle Intersection:1 ends here
