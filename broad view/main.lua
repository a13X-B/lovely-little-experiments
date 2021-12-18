--[[
TODO:
- fov
- textures
- add camera
- figure out default primitives
]]

local g = love.graphics

local R3 = require("R3helper")

g.setMeshCullMode("back")
g.setFrontFaceWinding("ccw")
g.setDepthMode("less", true)

--cube mesh
local vcf = {{"VertexPosition", "float", 3}}
local vtf = {{"VertexColor", "float", 3}}
local vc = {
	{-1,-1,-1}, {1,-1,-1}, {-1,-1,1}, {1,-1,1},
	{-1,1,-1}, {1,1,-1}, {-1,1,1}, {1,1,1}
}
local vt = {
	{0,0,0}, {1,0,0}, {0,0,1}, {1,0,1},
	{0,1,0}, {1,1,0}, {0,1,1}, {1,1,1}
}

local vm = {
	1,3,2, 2,3,4,
	5,6,7, 6,8,7,
	3,7,8, 3,8,4,
	1,6,5, 1,2,6,
	3,5,7, 1,5,3,
	4,8,6, 2,4,6,
}

local cube = g.newMesh(vcf, vc, "triangles", "static")
local tex = g.newMesh(vtf, vt, "triangles", "static")
cube:setVertexMap(vm)

cube:attachAttribute("VertexColor", tex)

R3.newProjection(true, g.getDimensions())

--takes axis angle representation
local function set_orientation(x,y,z,a)
	--let's turn axis angle to a quaternion, would've been great if we had one from the start
	local l = math.sqrt(x*x+y*y+z*z)
	x,y,z = x/l, y/l, z/l --normalize imaginary part
	local w, s = math.cos(a/2), math.sin(a/2) --the real part is a COsine of half an angle
	--the imaginary part will get multiplied by cosine of half an angle
	x,y,z = x*s, y*s, z*s -- so x, y, z, w is a quaternion now
	R3.rotate(x,y,z,w)
end

local c = g.newCanvas(g.getDimensions())

--love.mouse.setRelativeMode(true)
function love.mousemoved(x,y,dx,dy)
end

local k = love.keyboard
function love.update(dt)
end

function love.draw()
	local t = love.timer.getTime()
	R3.origin()
	--R3.translate(0,0,-10)
	set_orientation(0,1,0,t%(math.pi*2))
	--R3.translate(0,0,10)
	for i = -3,3,3 do
		for j = -3,3,3 do
			g.push()
			R3.translate(i,0,j)
			g.draw(cube)
			g.pop()
		end
	end
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
