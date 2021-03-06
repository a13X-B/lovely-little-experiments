local sprite = love.graphics.newImage("sprite.png")
sprite:setFilter("nearest")

local pl = love.graphics.newImage("p_light.png")
pl:setFilter("nearest")

local pd = love.graphics.newImage("p_dark.png")
pd:setFilter("nearest")

local masterpalette = love.graphics.newCanvas(32,1)
masterpalette:setFilter("nearest")

local shader = love.graphics.newShader("shader.glsl")

function love.draw()
  love.graphics.setCanvas(masterpalette)

  local offset = 0
  --offset = math.fmod(love.timer.getTime(),1)*20 --seizure warning

  love.graphics.draw(pl,offset,0)
  love.graphics.draw(pl,offset-20,0)
  
  --love.graphics.setColor(math.abs(math.sin(love.timer.getTime()*2)), 0.7, 0.7, 1) --hair color change by rendering a rectangle to a palette
  --love.graphics.rectangle("fill", 2,0,1,1)
  
  love.graphics.setColor(1,1,1,1)
  love.graphics.setCanvas()
  
  love.graphics.scale(10,10)
  love.graphics.setShader(shader)
  shader:send("pal", masterpalette)
  
  love.graphics.draw(sprite,0,0)
  love.graphics.setShader()
  love.graphics.draw(masterpalette, 0, 0)
end

function love.keypressed(k,s,r)
  if s == "escape" then love.event.quit(0) end
end
