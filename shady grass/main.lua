local w,h = love.graphics.getDimensions()
love.window.setMode(w, h, {msaa=8}) --smooth like fine wine

local s = 1/8

local p = {x=w*(1-0.69), y=0, vx = 0, vy = 0, l = false} --player
local pp = {}
local g = 1337 --gravity
local gr = h*0.69 --ground plane
local _dt

--graphics related stuff, mesh, shader, velocity buffers
local grass_blade_mesh = love.graphics.newMesh(16, "strip", "static") --we will generate geometry in the shader
local vb = {}
for i=1,2 do
  vb[i] = love.graphics.newCanvas(w*s, h*s, {type="2d", format="rg32f", readable=true, msaa=0, mipmaps="none"})
end
local gs = love.graphics.newShader("gs.glsl") --grass rendering shader
local vs = love.graphics.newShader("vs.glsl") --velocity shader
local vbs = love.graphics.newShader("vbs.glsl") --liquid dynamics shader

love.update = function(dt)
  _dt = dt
  pp.x, pp.y = p.x, p.y --I might need it 
  local d = (love.keyboard.isDown("left") and -1 or 0) + (love.keyboard.isDown("right") and 1 or 0) --move direction

  p.vx = d* (love.keyboard.isDown("lshift") and 123 or 321)
  p.x = p.x + p.vx*dt
  
  p.vy = (love.keyboard.isDown("up") and p.y >= gr-2) and -456.7 or p.vy + g*dt
  p.y = p.y + p.vy*dt
  if p.y > gr-1 then
    if p.vy > 200 then p.l = true end
    p.y, p.vy = gr-1, 0
  end
end

love.draw = function()
  love.graphics.draw(vb[1],0,0,0,8,8)
  love.graphics.setColor(0.7,0.2,0.2,1)
  love.graphics.rectangle("fill", p.x-15, p.y-69, 30, 69)
  
  love.graphics.setColor(1,1,1,1)

  love.graphics.setCanvas(vb[1])
  love.graphics.setShader(vs)
  love.graphics.setBlendMode("add")
  vs:send("vel",{p.vx,math.max(p.vy,0)})
  love.graphics.rectangle("fill", (p.x-5)*s, (p.y-69)*s, 10*s, 60*s)
  if p.l then
    p.l = false
    vs:send("vel",{p.vx+22222, 2222})
    love.graphics.rectangle("fill", (p.x+15)*s, (p.y-69)*s, 30*s, 50*s)
    vs:send("vel",{p.vx-22222, 2222})
    love.graphics.rectangle("fill", (p.x-45)*s, (p.y-69)*s, 30*s, 50*s)
    --draw landing
  end

  love.graphics.setBlendMode("replace")
  love.graphics.setCanvas(vb[2])
  love.graphics.setShader(vbs)
  --vbs:send("dt", _dt)
  love.graphics.draw(vb[1])
  vb[1], vb[2] = vb[2], vb[1] --swap buffers

  love.graphics.setCanvas()
  love.graphics.setShader(gs)
  gs:send("size", {w,h})
  gs:send("vb", vb[1])
  gs:send("dt", _dt)
  love.graphics.drawInstanced(grass_blade_mesh, math.floor(w/1.7*2))
  love.graphics.setShader()
  love.graphics.print("left/right to move\nup to jump\nleft shift to walk",10,30)
  love.graphics.print(love.timer.getFPS(),10,10)
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("fill",0,gr,w,100)
  love.graphics.setColor(1,1,1,1)
  love.graphics.line(-10, gr, w+20, gr)
end

love.keypressed = function(k,s,r)
  if s=='escape' then love.event.quit(0) end
end
