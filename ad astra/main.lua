local g = love.graphics

local seed = love.math.random()
local rnd = love.math.newRandomGenerator()
rnd:setSeed(seed)

local n = 1337 --amount of shiny stars


--stuff for a canvas based starfield
local w, h = g.getDimensions()
local sfq = g.newQuad(0,0,w,h,w,h) --quad for uv scrolling
local sf = g.newCanvas(w,h) --canvas where we will cache all the stars
sf:setWrap("repeat") --repeat mode for uv scrolling

--draw pixel wide squares at random points
g.setCanvas(sf)
for i=1,n do
	local x,y = rnd:random(w), rnd:random(h)
	g.rectangle("fill", x, y, 1,1)
end
g.setCanvas()

--mesh(points) based starfield
--we need 4x amount of stars so we can easily loop the field across the screen
local star_mesh = g.newMesh(n*4, "points")

local offsets = {{0,0},{w,0},{0,h},{w,h}}--offsets for repeated starpatterns

for j=1,4 do
	rnd:setSeed(seed) --reset seed so pattern repeats perfectly
	for i=1,n do --add stars to each quadrant
		local x,y = rnd:random(w) - offsets[j][1], rnd:random(h) - offsets[j][2]
		star_mesh:setVertex( (j-1)*n+i, x, y, 0, 0, 1, 1, 1, rnd:random() )
	end
end

--three dimensional starfield
--requires a 3rd dimension, duh
local vf = {
	{"VertexPosition", "float", 3},
	{"VertexColor", "byte", 4},
}

local star_mesh_3d = g.newMesh(vf, n*4, "points")
for i =1,n*4 do
	local x,y,z = rnd:random()*2-1, rnd:random()*2-1, rnd:random()*2-1
	local l = math.sqrt(x*x+y*y+z*z)
	if l == 0 then --one random vertex right in the center will ruin everything
		l,x,y,z = 1,1,0,0 --move it to the side
	end
	local d = 9.7+rnd:random()*.3
	x,y,z = d*x/l, d*y/l, d*z/l --put stars between a unit and two unit sphere
	z = z --lets us abuse love's internal clipping plane
	--not really sure if near plane +10 or -10 though
	star_mesh_3d:setVertex(i, x,y,z, 1,1,1,rnd:random()+.1)
end

local orient = love.math.newTransform()
local scale = love.math.newTransform(0,0,0,100,100)

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
		2*x*z+2*w*y, 2*y*z-2*w*x, 1-2*x*x-2*y*y, 10,
		0, 0, 0, 1
	)
	g.applyTransform(orient)
end

function love.draw()
	local ox, oy = love.timer.getTime()*33%w, love.timer.getTime()*15%h
	--ox, oy = love.mouse.getPosition()
	--[[canvas based starfield
	--to move the picture we actually move uv in the opposite direction
	sfq:setViewport(w-ox, h-oy, w,h)
	g.draw(sf,sfq)
	--]]
	
	--[[mesh based starfield
	g.draw(star_mesh, ox, oy)
	--]]
	---[[3d rotating sphere starfield
	g.translate(w/2,h/2)
	local s = love.mouse.getX()/8 --only needed for zoom effect
	g.scale(10+s, 10+s) --scales x and y but not z of a starfield
	--so it looks like an actual starfield and not a weird polka dot ball
	set_orientation( -1/3, -1, 0, love.timer.getTime()*.1 % math.pi*2)--axis angle
	g.draw(star_mesh_3d)
	--]]
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
