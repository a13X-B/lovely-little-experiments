local g = love.graphics

local img = g.newImage("screen.png")
local max_scale = 7 -- arbitrary number

local w,h = img:getDimensions()
local can = g.newCanvas(w*max_scale, h*max_scale)

local shader = g.newShader([[#pragma language glsl3
#ifdef PIXEL
	vec4 texture2DAA(sampler2D tex, vec2 uv) {
		vec2 texsize = vec2(textureSize(tex,0));
		vec2 uv_texspace = uv*texsize;
		vec2 seam = floor(uv_texspace+.5);
		uv_texspace = (uv_texspace-seam)/fwidth(uv_texspace)+seam;
		uv_texspace = clamp(uv_texspace, seam-.5, seam+.5);
		return Texel(tex, uv_texspace/texsize);
	}
	vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ){
		vec4 texcolor = texture2DAA(tex, texture_coords);
		return texcolor * color;
	}
#endif
]])

function love.draw()
	local x,y = love.mouse.getPosition()
	local w,h = img:getDimensions()
	x,y = x,y
	s = math.max(x/w, y/h)
	s = math.max(2,s)
	s = math.min(s,max_scale)
	g.setShader(shader)
	img:setFilter("linear")
	g.draw(img,0,0,0,s,s)
	g.setShader()
	g.setCanvas(can)
	g.scale(math.ceil(s))
	g.clear()
	img:setFilter("nearest")
	g.draw(img)
	g.origin()
	g.setCanvas()
	g.scale(s/(math.ceil(s)))
	if love.keyboard.isScancodeDown("1") then
		g.setBlendMode("subtract")
	end
	if love.keyboard.isScancodeDown("space") then
		g.draw(can)
	end
	g.origin()
	g.setBlendMode("alpha")
	g.print(s, x,y-20)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
