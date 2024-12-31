D = require "dds"
V = require "vec"

d = D.new(64,64,4)
print(d.width, d.height)
d:set(1,1, V.new(255,0,0, 255))
print(d:get(1,1):to_str())
d:save("d.dds")
