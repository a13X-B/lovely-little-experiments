local g = love.graphics

local R3 = require("R3helper")

g.setMeshCullMode("back")
g.setFrontFaceWinding("ccw")
g.setDepthMode("less", true)

local cube = require("ciwb")

local n = 16 --number of layers
local div = 1 --render at 1/div resolution
local w,h = g.getDimensions()
w,h = w/div,h/div

local layers = g.newCanvas(w,h,n,{type="array"})

local d = g.newCanvas(w,h, {format = "depth24", readable = true})
local pd = g.newCanvas(w,h, {format = "depth24", readable = true})
local dd = g.newCanvas(1,1, {format = "r8"}) --dummy depth sampler for the first layer

--instanced ciwbiau
local pf = {{"pos", "float", 3}}
local cubes = g.newMesh(pf, 32*32*32, nil, "dynamic")

local spread = 3
local id = 1
for i = 1,32 do
	for j = 1,32 do
		for k = 1,32 do
			cubes:setVertex(id, {spread*(i-16), spread*(k-16), spread*(j-16)})
			id = id+1
		end
	end
end

cube:attachAttribute("pos", cubes, "perinstance")

local oit_instanced = g.newShader("icube.glsl")

R3.newProjection(true, w,h)

local setup = {{}}

function love.draw()
	local t = love.timer.getTime()
	g.setDepthMode("less", true)
	R3.origin()
	R3.translate(0,0,2.5)
	R3.rotate(R3.aa_to_quat(0, 1, 0, .1*t%(math.pi*2)))
	R3.scale(.024, .024, .024)
	g.setShader(oit_instanced)

	--first layer with dummy depth sampler
	--pretty much the same as the loop later
	setup[1][1] = layers
	setup[1].layer = 1
	setup.depthstencil = d
	g.setCanvas(setup)
	g.clear()
	oit_instanced:send("d", dd)
	g.drawInstanced(cube, 32*32*32)
	for i = 2, n do --already have the first layer
		d,pd = pd,d --swap previous and current depthbuffer
		setup[1].layer = i -- render to the next layer
		setup.depthstencil = d -- with the empty depthbuffer(cleared later)
		oit_instanced:send("d", pd) --prev depth will be sampled to discard already rendered layers
		g.setCanvas(setup)
		g.clear() --clear canvas and depth
		g.drawInstanced(cube, 32*32*32)
	end

	g.setShader()
	g.setCanvas()
	g.origin()
	g.setDepthMode("always", false)
	g.setColor(1,1,1,.1) -- transparent layers
	for i = n,1,-1 do -- in reverse order
		g.drawLayer(layers,i,0,0,0,div,div)
	end
	g.setColor(1,1,1,1)
	g.print(love.timer.getDelta())
	g.print(g.getStats().drawcalls, 0, 20)
	g.print(love.timer.getFPS(), 0, 40)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
