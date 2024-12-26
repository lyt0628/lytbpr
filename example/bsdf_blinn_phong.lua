-- Main Code Block

-- [[file:../org_example/bsdf_blinn_phong.org::*Main Code Block][Main Code Block:1]]
package.path = package.path .. ";" .. "../src/util/?.lua"
local Vec = require("vec")
local Mat = require("mat")
local PPM = require("ppm")


local img = PPM.new(512, 512)

-- Light And Its Color
local L = Vec.new(0, 0, 0)
local L_c = Vec.new(255, 200, 100)

-- A factor to modify light value

local shinness = 8

local P = Vec.new(-1, 0, 0)
local A = Vec.new(10, -1700, 1550)
local B = Vec.new(13, 250, 500)
local C = Vec.new(10, 1200, 1000)

local AB = B - A
local AC = C - A
local N = Vec.cross3(AB, AC):normalized()

local AB_o = Vec.cross3(N, AB)
AB_o = AB_o / (AC:dot(AB_o))
local AC_o = Vec.cross3(N, AC)
AC_o = AC_o / (AB:dot(AC_o))


function test_ray_triangle_intersection(P, d, A, N)
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
        return true, Q
      end
end

local directions = {}
for z = -256, 255 do
  for y = -256, 255 do
     table.insert(directions, Vec.new(1, y, z))
  end
end
for r = 1, 512 do
  for c = 1, 512 do
     local d = directions[r + (c-1) * 512 ]
     local inside, Q = test_ray_triangle_intersection(P, d, A, N)
     if inside then
        
        local w_i = (Q - L)
        local w_o = d:scale(-1)
        
        local w_h = (w_i + w_o):normalized()
        
        
        local distance_to_light = #(w_i)
        local L_i = L_c / (4 * math.pi * distance_to_light^2) 
        print("L_i:", L_i:r(), L_i:g(), L_i:b())
        
        
        print( "Dot:" , w_h:dot(N))
        local blinn_phong_bsdf = math.max((w_h:dot(N)),0)^ shinness  * 1e21
        
        local L_o = L_i * blinn_phong_bsdf 
        print("L_o:", L_o[1], L_o[2], L_o[3] )
        img:set(r, c, L_o)
     end
  end
end

img:save("triangle_blinn_phong.ppm")
-- Main Code Block:1 ends here
