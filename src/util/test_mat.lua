-- Module

-- [[file:../../org_test/util/test_mat.org::*Module][Module:1]]
local Vec = require("vec")
local Mat = require("mat")
m3 = Mat.new({
      {1, 2, 3},    
      {4, 5, 6},    
      {7, 8, 9},    
})
assert(1==m3:get(1,1))
assert(6==m3:get(2,3))
assert(7==m3:get(3,1))
m3 = Mat.new({
      {1, 2, 3},    
      {4, 5, 6},    
      {7, 8, 9},    
})
assert(2==m3:rank())
m3 = Mat.new({
      {1, 2, 3},    
      {4, 5, 6},    
      {7, 8, 9},    
})
m3 = m3:simplified()
assert(1 == m3[1][1])

assert(1 == m3[2][2])

assert(0 == m3[3][3])
m3 = Mat.new({
      {1, 2, 3},    
      {4, 5, 6},    
      {7, 8, 9},    
})
m3 = m3:reduced()
print(m3:to_str())
assert(1 == m3[1][1])
assert(0 == m3[1][2])

assert(0 == m3[2][1])
assert(1 == m3[2][2])

assert(0 == m3[3][1])
assert(0 == m3[3][2])
-- Module:1 ends here
