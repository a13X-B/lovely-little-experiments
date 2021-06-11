local ffi = require("ffi")
ffi.cdef[[
  typedef struct vec2{double x,y;} vec2;
  typedef struct vec3{double x,y,z;} vec3;
  typedef struct vec4{double x,y,z,w;} vec4;
]]

local v2,v3,v4
local mt, vec = {}, {}, {}

local swizzler = setmetatable({
  [1] = function(s,k) assert(false, "reading non-existent component") return nil end,
  [2] = function(s,k) return v2(s[k:sub(1,1)],s[k:sub(2,2)]) end,
  [3] = function(s,k) return v3(s[k:sub(1,1)],s[k:sub(2,2)],s[k:sub(3,3)]) end,
  [4] = function(s,k) return v4(s[k:sub(1,1)],s[k:sub(2,2)],s[k:sub(3,3)],s[k:sub(4,4)]) end,
  }, {__index = function() assert(false, "wrong amount of arguments") return nil end,})

local swizzle_get = function(s, k) return swizzler[#k](s,k) end

local id = "xyzw"
local swizzle_set = function(s, k, val)
  assert(#k>1, "writing non-existent component")
  for i=1, #k do s[k:sub(i, i)] = val[id:sub(i,i)] end
end

mt[2] = {
  __unm = function(a) return v2(-a.x, -a.y) end,
  __add = function(a,b) assert(ffi.istype(a,b), "type mismatch") return v2(a.x+b.x, a.y+b.y) end,
  __sub = function(a,b) assert(ffi.istype(a,b), "type mismatch") return v2(a.x-b.x, a.y-b.y) end,
  __mul = function(a,b) return type(b)=="number" and v2(a.x*b,a.y*b) or type(a)=="number" and v2(b.x*a,b.y*a) or ffi.istype("vec2",b) and v2(a.x*b.x, a.y*b.y) or error"type mismatch" end,
  __div = function(a,b) return type(b)=="number" and v2(a.x/b,a.y/b) or ffi.istype("vec2",b) and v2(a.x/b.x, a.y/b.y) or error"type mismatch" end,
  __mod = function(a,b) return type(b)=="number" and v2(a.x%b,a.y%b) or ffi.istype("vec2",b) and v2(a.x%b.x, a.y%b.y) or error"type mismatch" end,
  --__pow = function(a,b) end,
  __len = function(a) return math.sqrt(a.x * a.x + a.y * a.y) end,
  __index = swizzle_get,
  __newindex = swizzle_set,
  __call = function(a) return a.x, a.y end,
}

mt[3] = {
  __unm = function(a) return v3(-a.x, -a.y, -a.z) end,
  __add = function(a,b) assert(ffi.istype(a,b), "type mismatch") return v3(a.x+b.x, a.y+b.y, a.z+b.z) end,
  __sub = function(a,b) assert(ffi.istype(a,b), "type mismatch") return v3(a.x-b.x, a.y-b.y, a.z-b.z) end,
  __mul = function(a,b) return type(b)=="number" and v3(a.x*b,a.y*b,a.z*b) or type(a)=="number" and v3(b.x*a,b.y*a,b.z*a) or ffi.istype("vec3",b) and v3(a.x*b.x, a.y*b.y, a.y*b.z) or error"type mismatch" end,
  __div = function(a,b) return type(b)=="number" and v3(a.x/b,a.y/b,a.z/b) or ffi.istype("vec3",b) and v3(a.x/b.x, a.y/b.y, a.y/b.z) or error"type mismatch" end,
  __mod = function(a,b) return type(b)=="number" and v3(a.x%b,a.y%b,a.z%b) or ffi.istype("vec3",b) and v3(a.x%b.x, a.y%b.y, a.y%b.z) or error"type mismatch" end,
  --__pow = function(a,b) end,
  __len = function(a) return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z) end,
  __index = swizzle_get,
  __newindex = swizzle_set,
  __call = function(a) return a.x, a.y, a.z end,
}

mt[4] = {
  __unm = function(a) return v4(-a.x, -a.y, -a.z, -a.w) end,
  __add = function(a,b) assert(ffi.istype(a,b), "type mismatch") return v4(a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w) end,
  __sub = function(a,b) assert(ffi.istype(a,b), "type mismatch") return v4(a.x-b.x, a.y-b.y, a.z-b.z, a.w-b.w) end,
  __mul = function(a,b) return type(b)=="number" and v4(a.x*b,a.y*b,a.z*b,a.w*b) or type(a)=="number" and v4(b.x*a,b.y*a,b.z*a,b.w*a) or ffi.istype("vec4",b) and v4(a.x*b.x, a.y*b.y, a.z*b.z, a.w*b.w) or error"type mismatch" end,
  __div = function(a,b) return type(b)=="number" and v4(a.x/b,a.y/b,a.z/b,a.w/b) or ffi.istype("vec4",b) and v4(a.x/b.x, a.y/b.y, a.z/b.z, a.w/b.w) or error"type mismatch" end,
  __mod = function(a,b) return type(b)=="number" and v4(a.x%b,a.y%b,a.z%b,a.w%b) or ffi.istype("vec4",b) and v4(a.x%b.x, a.y%b.y, a.z%b.z, a.w%b.w) or error"type mismatch" end,
  --__pow = function(a,b) end,
  __len = function(a) return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w) end,
  __index = swizzle_get,
  __newindex = swizzle_set,
  __call = function(a) return a.x, a.y, a.z, a.w end,
}

v2 = ffi.metatype("vec2", mt[2])
v3 = ffi.metatype("vec3", mt[3])
v4 = ffi.metatype("vec4", mt[4])

local m = math

vec.vec2 = v2
vec.vec3 = v3
vec.vec4 = v4

vec.vector = ffi.typeof("double[?]")
vec.vec2a = ffi.typeof("vec2[?]")
vec.vec3a = ffi.typeof("vec3[?]")
vec.vec4a = ffi.typeof("vec4[?]")

vec.normalize = function(a) return a/(#a) end --what about null vector?
vec.lerp = function(a, b, t) return a + (b-a)*t end
vec.abs = function(a)
  return ffi.istype("vec2", a) and v2(math.abs(a.x), math.abs(a.y))
      or ffi.istype("vec3", a) and v3(math.abs(a.x), math.abs(a.y), math.abs(a.z))
      or ffi.istype("vec4", a) and v4(math.abs(a.x), math.abs(a.y), math.abs(a.z), math.abs(a.w))
end
vec.dot = function(a, b)
  return ffi.istype("vec2", a) and a.x*b.x + a.y*b.y
      or ffi.istype("vec3", a) and a.x*b.x + a.y*b.y + a.z*b.z
      or ffi.istype("vec4", a) and a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w
end
vec.cross = function(a, b) return v3(a.y*b.z - b.y*a.z, a.z*b.x - b.z*a.x, a.x*b.y - b.x*a.y) end
vec.cross2d = function(a,b) return a.x*b.y - b.x*a.y end
vec.conj = function(a) return ffi.istype("vec4", a) and v4(-a.x, -a.y, -a.z, a.w) or ffi.istype("vec2", a) and v2(a.x, -a.y) or error"only vec2 and vec4 have conjugates" end
vec.cmul = function(a, b) return v2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x)end
vec.qmul = function(a, b) return v4(a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
                                    a.w*b.y + a.y*b.w + a.z*b.x - a.x*b.z,
                                    a.w*b.z + a.z*b.w + a.x*b.y - a.y*b.x,
                                    a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z)
end

assert( #(v2(1,1)) == m.sqrt(2), "can't proceed with vectoring: # operator is not supported")

return vec