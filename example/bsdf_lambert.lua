-- Main Code Block

-- [[file:../org_example/bsdf_lambert.org::*Main Code Block][Main Code Block:1]]
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
      local AB_o = AB_o / (AC:dot(AB_o))
      local AC_o = AC_o / (AB:dot(AC_o))
      local u = N:dot(d)
      
      if(u == 0) then
       -- print("Ray parall with Plane")
        return false
      end
      
      if math.abs(u) < 1e-15 then
       -- print("Unstable")
        return false
      end
      
      
      t = ((A-P):dot(N))/u
      
      if t < 0 then
       -- print("Ray miss plane")
        return false
      end
      
      
      local Q = P + t * d
      
      local c = (Q - C):dot(AC_o)
      local b = (Q - B):dot(AB_o)
      local a = 1 - (b + c)
      
      if a < 0 or a > 1 or b < 0 or b > 1 or c < 0 or c > 1 then
       -- print("Out of triangle,", a, b, c)
        return false
      
      else
        print("Inside triangle,", a, b, c)
      
        -- Return a Extra Position of Intersection Point
        return true, Q, N
      end
end

local img = PPM.new(64, 64)

-- Light And Its Color
local L = Vec.new(0, 0, 0)
local L_c = Vec.new(255, 200, 100)

-- A factor to modify light value
local lambert_factor = Vec.new(36, 36, 36)

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
     local inside, Q, N = test_ray_triangle_intersection(P, directions[r + (c-1)*64 ],A,B,C)
     if (inside) then
         local distance_to_light = #(Q-L)
         print("Distance:" .. distance_to_light)
         local L_i = L_c / ( distance_to_light^2) * 15
         print("L_i:" .. L_i:r(),L_i:g(),L_i:b() )
         N = N:normlized()
        -- print("N: " .. N[1], N[2], N[3] ,#N)
         local D =  (Q-L):normlized()
        -- print("D: " .. D[1], D[2], D[3])
        -- print("Dot:" .. N:dot(D))
         local L_o = L_i * lambert_factor * math.max(0, N:dot(D))
        -- print("Output Color:" .. L_o[1],L_o[2],L_o[3] )
         img:set(r, c, L_o)
     end
  end
end

img:save("triangle_lambert.ppm")
-- Main Code Block:1 ends here
