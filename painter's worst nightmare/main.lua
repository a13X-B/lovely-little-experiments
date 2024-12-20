local g = love.graphics
local w,h = love.graphics.getDimensions()

local rnd = love.math.newRandomGenerator()
local rnd_state = rnd:getState()

local alpha_shader = g.newShader("shader.glsl")

local coverage_lut = g.newImage("lut.png", {linear=true})
coverage_lut:setFilter("nearest") -- absolutely don't wanna interpolate bitmasks
coverage_lut:setWrap("repeat","clamp")

local rgb = {
	{1,0,0,.7},
	{0,1,0,.7},
	{0,0,1,.7},
}

local pic = g.newCanvas(1,1)
g.setCanvas(pic); g.rectangle("fill",0,0,1,1); g.setCanvas()

local thing = g.newSpriteBatch(pic,3)
for i=1,3 do
	thing:setColor(rgb[i])
	thing:add(0,0,(1-i)*math.pi*2/3,w/3,h/13,.5,-.4)
end

function love.update(dt)
end

local superscale = 2 -- more than two requires a different downsampling method
local iter = 4 -- number of iterations, 
-- final calculation is average of superscale squared by iter of msaa graded alpha

local screen = g.newCanvas(w*superscale,h*superscale,{msaa=8})
local screen_set = {screen, depth=true}
local function draw_scene()
	g.setCanvas(screen_set)
	g.clear()
	alpha_shader:send("lut", coverage_lut)
	 -- random offset so iterations don't repeat the same pattern
	alpha_shader:send("alpha_offset", rnd:random())
	g.setShader(alpha_shader)
	g.setDepthMode("less", true)
	g.draw(thing, w/2*superscale, h/2*superscale, 0, superscale, superscale)
	g.setDepthMode()
	g.setShader()
	g.setCanvas()
end

function love.draw()
	local avg = 1/iter
	rnd:setState(rnd_state)
	for i = 1, iter do
		draw_scene()
		g.setColor(love.math.linearToGamma(avg,avg,avg,1))
		g.setBlendMode("add", "premultiplied")
		g.draw(screen,0,0,0, 1/superscale, 1/superscale)
		g.setColor(1,1,1,1)
		g.setBlendMode("alpha")
	end
	g.setColor(0,0,0)
	g.rectangle("fill",0,0,200,40)
	g.setColor(1,1,1)
	g.print(love.timer.getDelta())
	g.print(love.timer.getFPS(),0,20)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
