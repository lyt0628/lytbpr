-- Main Code Block

-- [[file:org/bsdf_phong_light.org::*Main Code Block][Main Code Block:1]]
require("conf_path")
local Vec = require("vec")
local Mat = require("mat")
local PPM = require("ppm")
local Ray = require("ray")
function to_pixel(value_in_cm)
   return 26 * value_in_cm
end

local A = Vec.new(to_pixel(1.7641), to_pixel(-147.445), to_pixel(-225.5))
local B = Vec.new(to_pixel(0.21684), to_pixel(-89.257), to_pixel(129.431))
local C = Vec.new(to_pixel(0.71684), to_pixel(248.68), to_pixel(80.808))
local P = Vec.new(to_pixel(-1), 0, 0)
local viewport = PPM.new(512, 512)
local directions = {}
for z = -256, 255 do
  for y = -256, 255 do
     table.insert(directions, Vec.new(1, y, z))
  end
end
-- Light And Its Color
local L = Vec.new(to_pixel(-100), to_pixel(100), 0)
local L_c = Vec.new(55, 200, 0)

print("L_c is: ", L_c:to_str())


local L_env = Vec.new(20, 20, 20) 

local AB = B - A
local AC = C - A
local N = Vec.cross3(AB, AC):normalized()

local AB_o = Vec.cross3(N, AB)
AB_o = AB_o / (AC:dot(AB_o))
local AC_o = Vec.cross3(N, AC)
AC_o = AC_o / (AB:dot(AC_o))

print("Normal Of Triangle: ", N:to_str())
print("Axis AB_o of Wight Coordinate: ", AB_o:to_str())
print("Axis AC_o of Wight Coordinate: ", AC_o:to_str())
print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")

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
function BSDF(L_i, L_o, surfaceInfo)
  local attenuation
  local R = L_i - 2 * (L_i * surfaceInfo.normal) * surfaceInfo.normal
  local shinness = 3
  
  local ratio = math.max((R:dot(L_o)), 0)^ shinness  * 1e10
  attenuation = Vec.new(ratio, ratio, ratio)
  return attenuation
end
for r = 1, 512 do
  for c = 1, 512 do
     local inside, Q = test_ray_triangle_intersection(P, directions[r + (c-1) * 512 ], A, N)
     if inside then
         local incident_vector = Q - L
         local distance_to_light = #(incident_vector)
         local incident_direction = incident_vector:normalized()
         local reflected_direction = (P - Q):normalized()


         local distance_attenuation = 1 / (4 * math.pi * distance_to_light^2)
         print("Distance Attenuation: ", distance_attenuation)
         local l = L_c * distance_attenuation  -- Distance Attenuation
         print("L_c with Distance Attenuation: ", l:to_str())

         local tilt_attenuation = N:dot(incident_direction:scale(-1))
         print("Tilt Attenuation Without Campled: ", tilt_attenuation)
         l = l * math.max(0, tilt_attenuation) -- Titel Attenuation
         print("L_c with Tilt Attenuation: ", L_c:to_str())


         local surfaceInfo = {}
         surfaceInfo.normal = N
         local bsdf_attenuation = BSDF(incident_direction, reflected_direction, surfaceInfo)
         print("BSDF Attenuation: ", bsdf_attenuation:to_str())

         local pixel = l * bsdf_attenuation  + L_env
         print("Final Color: ", pixel:to_str())
         print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
         viewport:set(r,c, pixel)
     end
  end
end
viewport:save("triangle_phong.ppm")
-- Main Code Block:1 ends here
