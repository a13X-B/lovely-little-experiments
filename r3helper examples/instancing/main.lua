local g = love.graphics

local R3 = require("R3helper")

g.setMeshCullMode("back")
g.setFrontFaceWinding("ccw")
g.setDepthMode("less", true)

local cube = require("ciwb")

R3.newProjection(true, g.getDimensions())

local pf = {{"pos", "float", 3}}
local cubes = g.newMesh(pf, 32*32*32, nil, "dynamic")

local spread = 7
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

local icube = g.newShader("icube.glsl")

function love.draw()
	local t = love.timer.getTime()
	g.setDepthMode("less", true)
	R3.origin()
	R3.translate(0,0,2.5)
	R3.rotate(R3.aa_to_quat(0, 1, 0, .1*t%(math.pi*2)))
	--[[ run this code if you want to compare the speed with rendering one by one
	for i = 1,32 do
		for j = 1,32 do
			for k = 1,32 do
				g.push()
				R3.scale(.01,.01,.01)
				R3.translate(spread*(i-16), spread*(k-16), spread*(j-16))
				g.draw(cube)
				g.pop()
			end
		end
	end
	--]]
	g.setShader(icube)
	local s = .011 - .001*math.cos(t*.0001)
	R3.scale(s, s, s)
	g.drawInstanced(cube, 32*32*32)
	g.setShader()
	g.origin()
	g.setDepthMode("always", false)
	g.print(love.timer.getDelta())
	g.print(g.getStats().drawcalls, 0, 20)
	g.print(love.timer.getFPS(), 0, 40)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
