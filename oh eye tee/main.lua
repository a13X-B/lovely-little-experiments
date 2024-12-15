local g = love.graphics
local rnd = love.math.newRandomGenerator()
local w,h = love.graphics.getDimensions()

local ffi = require"ffi"

local number_of_bubbles = 666
local number_of_dudes = 111
local dude_velocity = 60

local depth_shader = g.newShader("shader.glsl")

local coverage_lut = g.newImage("lut.png", {linear=true})
coverage_lut:setFilter("nearest") -- absolutely don't wanna interpolate bitmasks
coverage_lut:setWrap("repeat","clamp")

local dude_sprite = g.newImage("dude.png")
local dude_frames = {}
for i=1,4 do
	dude_frames[i] = g.newQuad(64*(i-1),0,64,64,256,64)
end

local dudes = {}
local batch_of_dudes = g.newSpriteBatch(dude_sprite,number_of_dudes)
for i = 1,number_of_dudes do
	local dude = {
		x = rnd:random(-100, w+100),
		y = rnd:random(-100, h+100),
		dest_x = rnd:random(-100, w+100),
		dest_y = rnd:random(-100, h+100),
		t = math.max(rnd:random()-.5, 0),
		d_walked = 0
	}
	dude.dir = dude.dest_x > dude.x and 1 or -1
	dudes[i] = dude
	batch_of_dudes:add(0,0)
end

local function update_dudes(dt)
	for _, dude in ipairs(dudes) do
		local dx, dy = dude.dest_x - dude.x, dude.dest_y - dude.y
		local d = math.sqrt(dx*dx+dy*dy)
		if dude.t > 0 then
			dude.t = dude.t - dt*10
		elseif d < dude_velocity*dt then
			dude.x, dude.y = dude.dest_x, dude.dest_y
			dude.t = rnd:random(27,175)
			dude.dest_x = rnd:random(-100, w+100)
			dude.dest_y = rnd:random(-100, h+100)
			dude.dir = dude.dest_x > dude.x and 1 or -1
		else
			dude.x = dude.x + dude_velocity*dt*dx/d
			dude.y = dude.y + dude_velocity*dt*dy/d
			dude.d_walked = (dude.d_walked + dude_velocity*dt)%30
		end
	end
	dudes[1].x = w/2
	dudes[1].y = h/2
	for i, dude in ipairs(dudes) do
		local quad
		if dude.t > 0 then
			local idle_index = math.floor((dude.t%13)/9) -- 0 or 1 in idle
			quad = dude_frames[1+idle_index]
		else 
			local walk_index = math.floor(dude.d_walked/15) -- 0 ir 1 in walking
			quad = dude_frames[3+walk_index]
		end
		batch_of_dudes:set(i,quad,math.floor(dude.x),math.floor(dude.y),0,dude.dir,1,32,64,0,0)
	end
end

local bubble_sprite = g.newImage("bubble.png")
local bubble_frames = {}
for i=1,2 do
	bubble_frames[i] = g.newQuad(64*(i-1),0,64,84,128,64)
end

local bubbles = {}
local batch_of_bubbles = g.newSpriteBatch(bubble_sprite, number_of_bubbles)
for i = 1, number_of_bubbles do
	local bubble = {
		x = rnd:random(-200, w+100),
		y = rnd:random(100, h+100),
		f = rnd:random(1,2),
		vel = rnd:random(33,77)
	}
	bubbles[i] = bubble
	batch_of_bubbles:add(0,0)
end

local function update_bubbles(dt)
	for _, bubble in ipairs(bubbles) do
		bubble.x = bubble.x + bubble.vel*dt
		if bubble.x > w+32 then
			bubble.x = rnd:random(-w-100, -100)
			bubble.y = rnd:random(100, h+100)
			bubble.f = rnd:random(1,2)
		end
	end
	bubbles[1].x = w/2
	bubbles[1].y = h/2
	for i, bubble in ipairs(bubbles) do
		local quad = bubble_frames[bubble.f]
		batch_of_bubbles:set(i,quad,math.floor(bubble.x),math.floor(bubble.y),0,1,1,32,84,0,0)
	end
end

function love.update(dt)
	update_dudes(dt)
	update_bubbles(dt)
end

local superscale = 2 -- more than two requires a different downsampling method
local iter = 4 -- number of iterations, 
-- final calculation is average of superscale squared by iter of msaa graded alpha

local screen = g.newCanvas(w*superscale,h*superscale,{msaa=8})
local screen_set = {screen, depth=true}
local function draw_scene()
	g.setCanvas(screen_set)
	g.clear()
	depth_shader:send("lut", coverage_lut)
	depth_shader:send("depth_scale", h*(superscale+1))
	depth_shader:send("mask_offset", rnd:random())
	depth_shader:send("depth_offset", 64*superscale)
	g.setShader(depth_shader)
	g.setDepthMode("less", true)
	g.draw(batch_of_dudes,0,0,0,superscale,superscale)
	depth_shader:send("depth_offset", 96*superscale)
	g.draw(batch_of_bubbles,0,0,0,superscale,superscale)
	g.setDepthMode()
	g.setShader()
	g.setCanvas()
end

function love.draw()
	local avg = 1/iter
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
