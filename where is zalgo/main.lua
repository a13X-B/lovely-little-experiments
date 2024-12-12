local g = love.graphics
local rnd = love.math.newRandomGenerator()
local w,h = love.graphics.getDimensions()

local sort_en = true
local number_of_dudes = 5000
local dude_velocity = 60

local function sort(a,b) return a.y<b.y end

local depth_shader = g.newShader("shader.glsl")

local dude_sprite = g.newImage("dude.png")
local dude_frames = {
	g.newQuad(0,0,32,32,128,32),
	g.newQuad(32,0,32,32,128,32),
	g.newQuad(64,0,32,32,128,32),
	g.newQuad(96,0,32,32,128,32)
}
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

function love.update(dt)
	--move dudes
	for _, dude in ipairs(dudes) do
		local dx, dy = dude.dest_x - dude.x, dude.dest_y - dude.y
		local d = math.sqrt(dx*dx+dy*dy)
		if dude.t > 0 then -- idle
			dude.t = dude.t - dt*10
		elseif d < dude_velocity*dt then -- change direction and wait a bit
			dude.x, dude.y = dude.dest_x, dude.dest_y
			dude.t = rnd:random(10,105)
			dude.dest_x = rnd:random(-100, w+100)
			dude.dest_y = rnd:random(-100, h+100)
			dude.dir = dude.dest_x > dude.x and 1 or -1
		else -- walk around
			dude.x = dude.x + dude_velocity*dt*dx/d
			dude.y = dude.y + dude_velocity*dt*dy/d
			dude.d_walked = (dude.d_walked + dude_velocity*dt)%20
		end
	end
	if sort_en then
		table.sort(dudes,sort)
	end
	for i, dude in ipairs(dudes) do
		local quad
		if dude.t > 0 then
			local idle_index = math.floor((dude.t%3)/1.5) -- 0 or 1 in idle
			quad = dude_frames[1+idle_index]
		else 
			local walk_index = math.floor(dude.d_walked/10) -- 0 ir 1 in walking
			quad = dude_frames[3+walk_index]
		end
		batch_of_dudes:set(i,quad,math.floor(dude.x),math.floor(dude.y),0,dude.dir,1,16,32,0,0)
	end
end

function love.draw()
	if not sort_en then
		g.setShader(depth_shader)
		depth_shader:send("depth_scale", h*2)
		g.setDepthMode("less", true)
	end
	g.draw(batch_of_dudes)
	g.setDepthMode()
	g.setShader()
	g.setColor(0,0,0)
	g.rectangle("fill",0,0,200,60)
	g.setColor(1,1,1)
	g.print(love.timer.getDelta())
	g.print(love.timer.getFPS(),0,20)
	g.print("sort: "..tostring(sort_en).." (space to change)",0,40)
end

function love.keypressed(k,s,r)
	if k == "space" then sort_en = not sort_en end
	if k == "escape" then love.event.quit(0) end
end
