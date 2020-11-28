local scale = 1/5 --smaller scale == bigger pixels
local max_offset = 3 --how far will smoky thing offset randomly
local fdt = 1/120 --fixed delta for the fixed tickrate
local fade_rate = 1/60 --how much to fade per tick

local g = love.graphics
local w,h = g.getDimensions()

local fadebuffer = g.newCanvas(w*scale, h*scale, {format = "r8", msaa = 0})
fadebuffer:setFilter("nearest", "nearest")
local shader = g.newShader("shader.glsl")
shader:send("scale", scale)

local function get_offset()
	return love.math.random(-max_offset,max_offset)
end

local function tick()
	g.origin()
	g.setCanvas(fadebuffer)

	g.scale(scale, scale)
	g.translate(love.mouse.getPosition())
	g.setBlendMode("lighten", "premultiplied")
	local offset_x, offset_y = get_offset(), get_offset()
	for i = 1, 10 do
		g.setColor(i/10, 1, 1, 1)
		g.circle("fill", offset_x*5, offset_y*5, 55-(35/9)*i)
	end

	g.setBlendMode("subtract", "alphamultiply")
	g.setColor(fade_rate, 1, 1, 1)
	g.origin()
	g.rectangle("fill", 0, 0, w, h)
	g.reset()
end

local t = 0
function love.update(dt)
	t = t + dt
	while t > fdt do
		tick()
		t = t - fdt
	end
end

function love.draw()
	g.setShader(shader)
	g.draw(fadebuffer, 0, 0, 0, 1/scale, 1/scale)
	g.setShader()
	g.translate(love.mouse.getPosition())
	g.circle("fill", 0, 0, 50)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
