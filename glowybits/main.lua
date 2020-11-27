local g = love.graphics

local w,h = g.getDimensions()

local fdt = 1/120

local scale = 5

local fadebuffer = g.newCanvas(w/scale,h/scale,{format = "r8", msaa = 0})
fadebuffer:setFilter("nearest", "nearest")
local shader = g.newShader("shader.glsl")

local max_offset = 3
local function get_offset()
	return love.math.random(-max_offset,max_offset)
end

local function fupdate()
	g.origin()
	g.scale(1/scale, 1/scale)
	g.setCanvas(fadebuffer)
	
	g.translate(love.mouse.getPosition())
	g.setBlendMode("lighten", "premultiplied")
	local offset_x, offset_y = get_offset(), get_offset()
	for i = 1, 10 do
		g.setColor(i/10, 1, 1, 1)
		g.circle("fill", offset_x*5, offset_y*5, 55 - (35/9)*i)
	end
	g.setBlendMode("subtract", "alphamultiply")
	g.setColor(1/60, 1, 1, 1)
	g.origin()
	g.rectangle("fill",0,0,w,h)
	g.reset() --kind of an overkill?
end

local t = 0
function love.update(dt)
	t = t + dt
	while t > fdt do
		fupdate()
		t = t - fdt
	end
end

function love.draw()
	g.setShader(shader)
	g.draw(fadebuffer,0,0,0,scale,scale)
	g.setShader()
	g.translate(love.mouse.getPosition())
	g.circle("fill", 0, 0, 50)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
