local fdt = 1/125
local t = 0

local v = require("vectoring")

local p = v.vec2()
local a = v.vec2()
local V = v.vec2()
local C = v.vec2()

local alt = 0
local r = 0.1
local S = 15

function set_glider(x, y)
  p.xy = v.vec2(x,y)
  V.xy = v.vec2()
end


function fixed_update(dt)
  C.xy = v.vec2()
  
  local l = #V
  local b = r*l*l*0.5*S
  local AF = C*b*v.vec2(S,S2)


end

function love.update(dt)
  t = t + math.min(dt, fdt*8)

  while t >= fdt do
    fixed_update(fdt)
    t = t - fdt
  end
end

function love.draw()
  
end

function love.mousepressed(x,y,n,t)
  set_glider(x, y)
end

function love.keypressed(k,s,r)
  if k=="escape" then love.event.quit() end
end
