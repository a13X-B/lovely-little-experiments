--[[
TODO:
- fix winding
- fov
- figure out z projection
- textures
- add camera
- make a module
]]

local g = love.graphics

local w, h = g.getDimensions()
local ar = w/h -- aspect ratio

g.setMeshCullMode("none") -- no cull yet, winding is busted
g.setDepthMode("less", true)

local shader = g.newShader("shader.glsl")

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
	1,2,3, 4,3,2,
	5,7,6, 6,7,8,
	3,8,7, 3,4,8,
	1,5,6, 1,6,2,
	3,7,5, 1,3,5,
	4,6,8, 4,2,6,
	}

local cube = g.newMesh(vcf, vc, "triangles", "static")
local tex = g.newMesh(vtf, vt, "triangles", "static")
cube:setVertexMap(vm)

cube:attachAttribute("VertexColor", tex)

--simple projection matrix
local projection = love.math.newTransform():setMatrix(
	1/ar, 0, 0, 0,
	0, 1, 0, 0,
	0, 0, 1, 0,
	0, 0, 1, 1
)

local scale = love.math.newTransform():setMatrix(
	.3, 0, 0, 0,
	0, .3, 0, 0,
	0, 0, .3, 0,
	0, 0, 0, 1
)

local translate = love.math.newTransform():setMatrix(
	1, 0, 0, 0,
	0, 1, 0, 0,
	0, 0, 1, 2,
	0, 0, 0, 1
)

local orient = love.math.newTransform()

--takes axis angle representation
local function set_orientation(x,y,z,a)
	--let's turn axis angle to a quaternion, would've been great if we had one from the start
	local l = math.sqrt(x*x+y*y+z*z)
	assert(l ~= 0, "learn a thing or two about axis angle representation or quats")
	x,y,z = x/l, y/l, z/l --normalize imaginary part
	local w, c = math.sin(a/2), math.cos(a/2) --the real part is a sine of half an angle
	--the imaginary part will get multiplied by cosine of half an angle
	x,y,z = x*c, y*c, z*c -- so x, y, z, w is a quaternion now
	orient:setMatrix( --that's a normalized quaternion to matrix conversion
		1-2*y*y-2*z*z, 2*x*y+2*w*z, 2*x*z-2*w*y, 0,
		2*x*y-2*w*z, 1-2*x*x-2*z*z, 2*y*z+2*w*x, 0,
		2*x*z+2*w*y, 2*y*z-2*w*x, 1-2*x*x-2*y*y, 0,
		0, 0, 0, 1
	)
	g.applyTransform(orient)
end

local final_transform = love.math.newTransform()
function love.draw()
	final_transform:reset()
	final_transform:apply(projection)
	final_transform:apply(translate)
	--final_transform:apply(scale)
	final_transform:apply(orient)
	shader:send("transform", final_transform)
	g.setShader(shader)
	local t = love.timer.getTime()
	set_orientation( math.cos(t*.1), math.sin(t*.1), 0, t % math.pi*2)--axis angle

	g.draw(cube)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
