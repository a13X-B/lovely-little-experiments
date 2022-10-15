local g = love.graphics

local quad = g.newCanvas(1,1)

local shader = g.newShader("shader.glsl")
local w,h = g.getDimensions()
local t = love.timer.getTime

function love.draw()
	g.setShader(shader)
	shader:send("iTime", t())
	g.draw(quad, 0,0, 0, w,h)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
