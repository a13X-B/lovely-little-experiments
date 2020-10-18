local fl = {mipmaps = true}
local cm = love.graphics.newImage("C1W.png", fl)
local dm = love.graphics.newImage("D1.png", fl)
local mr = "mirroredrepeat"
cm:setWrap(mr,mr)
dm:setWrap(mr,mr)
cm:setFilter("nearest")
dm:setFilter("nearest")

local rows = 1024
local vt_shader = love.graphics.newShader("vt.glsl")
local vt_mesh = love.graphics.newMesh(4*400*rows, "triangles","static")
--we're doing merege instancing because hw instancing for quads is suboptimal
--*when* null vertex buffers are implemented in love we won't need no mesh at all

local vert_map = {}

for i=1,400*rows do
  local o = i*4-4
  vert_map[#vert_map+1] = 1+o
  vert_map[#vert_map+1] = 2+o
  vert_map[#vert_map+1] = 3+o
  vert_map[#vert_map+1] = 3+o
  vert_map[#vert_map+1] = 2+o
  vert_map[#vert_map+1] = 4+o
end
vt_mesh:setVertexMap(vert_map) --this index buffer is there to make things simpler in vs
vt_mesh:setTexture(cm)

local map = love.graphics.newQuad(0,0,1024,1024,1024,1024)

local controls = {fwd=0, bwd=0, stl=0, str=0, ll=0, lr=0, uwd=0, dwd=0,}
local bindings = {w="fwd", a="stl", s="bwd", d="str", q="ll", e="lr", space = "uwd", lshift = "dwd"}
local sens = 0.002

local px,py,pz, dx,dy = 0,0,120,1,0
local v = 100

love.mouse.setRelativeMode(true)

function cam_rotate(a)
  local c, s = math.cos(a), math.sin(a)
  dx,dy = dx*c-dy*s, dx*s+dy*c
  local l = math.sqrt(dx*dx+dy*dy)
  dx, dy = dx/l, dy/l
end

function love.update(dt)
  local forward = controls.fwd - controls.bwd
  local rightward = controls.stl - controls.str
  local upward = controls.uwd - controls.dwd
  local vx, vy, vz = (forward*dx + rightward*dy)*v*dt, (forward*dy - rightward*dx)*v*dt, upward*v*dt*0.75
  local a = controls.lr - controls.ll
  cam_rotate(a * math.pi*0.5 * dt)
  px, py, pz = (px + vx)%2048, (py + vy)%2048, math.max(25, math.min(pz+vz, 166))
end

function love.draw()
  love.graphics.setDepthMode("less", true)
  vt_shader:send("dm", dm)
  vt_shader:send("dir", {dx, dy})
  vt_shader:send("pos", {px, py, pz})
  love.graphics.setShader(vt_shader)
  love.graphics.draw(vt_mesh)--this line is the raycasting part :D
  love.graphics.reset()
  map:setViewport(0+px, 0+py, 1024, 1024)
  love.graphics.scale(1/8,1/8)
  love.graphics.draw(cm,map,0,0)
  love.graphics.reset()
  love.graphics.setColor(0,1,0,1)
  love.graphics.polygon("fill",64+dx*16,64+dy*16, 64-dy*2,64+dx*2, 64+dy*2,64-dx*2)
  love.graphics.reset()
  love.graphics.print("WASD+shift+space to move\nQE and/or mouse to look\nFPS:"..love.timer.getFPS(), 600, 10)
end

function love.mousemoved(x,y,ox,oy)
  cam_rotate(ox*sens)
end

function love.keypressed(k,s,r)
  if s == "escape" then love.event.quit(0) end
  if bindings[s] then controls[bindings[s]] = 1 end
end

function love.keyreleased(k,s)
  if bindings[s] then controls[bindings[s]] = 0 end
end