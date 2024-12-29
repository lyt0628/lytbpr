
local root = "../src"

local path = root .. "/?.lua;"
path = path .. root .. "/util/?.lua"




package.path = package.path .. path
