--[[
TODO:
- fov
- figure out z projection
- textures
- add camera
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
	local w, c = math.sin(a/2), math.cos(a/2) --the real part is a sine of half an angle
	--the imaginary part will get multiplied by cosine of half an angle
	x,y,z = x*c, y*c, z*c -- so x, y, z, w is a quaternion now
	R3.rotate(x,y,z,w)
end

local c = g.newCanvas(g.getDimensions())

function love.draw()
	local t = love.timer.getTime()
	g.draw(c)
	--g.setCanvas({c, depth=true})
	g.clear()
	R3.origin()
	R3.scale(.1,.1,.1)
	--R3.translate(1,math.sin(t),1)
	set_orientation( 0, 1, 0, t % math.pi*2)--axis angle
	g.draw(cube)
	g.setCanvas()
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
