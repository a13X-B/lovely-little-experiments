local g = love.graphics

local lights = require("lights")
local w,h = love.graphics.getDimensions()

local static_map = {}
local dynamic_crap = {}

local light_shader = g.newShader("light_shader.glsl")
local shadowmap_shader = g.newShader("shadow_map.glsl")

local rnd= love.math.newRandomGenerator(31337)

--generate static geometry
--a bunch of randomly placed and oriented rectangles
for i=1,13 do
	static_map[i] = {
		pos = {rnd:random(0,w), rnd:random(0,h)},
		dimensions = {rnd:random(20,100), 10},--half dimensions
		orientation = rnd:random()*math.pi,
	}
end

--generate dynamic geometry
for i=1,54 do
	local size = rnd:random(10, 30)
	dynamic_crap[i] = {
		pos = {rnd:random(0,w), rnd:random(0,h)},
		dimensions = {size, size},--half dimensions
		orientation = rnd:random()*math.pi,
		rotation = rnd:random(1,5),
	}
end

--shadow mesh stuff
--that's the meat of this algo
--we want everything that casts shadow to be in a single mesh
local max_edges = 10000
local shadow_vf = {{"VertexPosition", "float", 3}}
local shadow_geometry = g.newMesh(shadow_vf, max_edges*6, "triangles", "stream")
shadow_geometry:attachAttribute("lpos", lights.pos, "perinstance")

local transform = love.math.newTransform()
local edge = 1

--not the prettiest but quite efficient way of setting the given edge triangles
local vert1 = {0,0,0}
local vert2 = {0,0,0}
local function set_edge(i, x1,y1, x2,y2)
	local vi = 6*(i-1)
	vert1[1], vert1[2], vert1[3] = x1, y1, 0
	vert2[1], vert2[2], vert2[3] = x2, y2, 0
	shadow_geometry:setVertex(vi+1, vert1)
	vert1[3] = 1
	shadow_geometry:setVertex(vi+2, vert1)
	shadow_geometry:setVertex(vi+3, vert2)
	shadow_geometry:setVertex(vi+4, vert2)
	vert2[3] = 1
	shadow_geometry:setVertex(vi+5, vert2)
	shadow_geometry:setVertex(vi+6, vert1)
end

for i, v in ipairs(static_map) do
	transform:reset()
	transform:translate(v.pos[1], v.pos[2])
	transform:rotate(v.orientation)
	local p1x, p1y = transform:transformPoint(-v.dimensions[1], -v.dimensions[2])
	local p2x, p2y = transform:transformPoint( v.dimensions[1], -v.dimensions[2])
	local p3x, p3y = transform:transformPoint( v.dimensions[1],  v.dimensions[2])
	local p4x, p4y = transform:transformPoint(-v.dimensions[1],  v.dimensions[2])
	set_edge(edge, p1x, p1y, p2x, p2y); edge = edge+1
	set_edge(edge, p2x, p2y, p3x, p3y); edge = edge+1
	set_edge(edge, p3x, p3y, p4x, p4y); edge = edge+1
	set_edge(edge, p4x, p4y, p1x, p1y); edge = edge+1
end

local shadow_array = g.newCanvas(w, h, 2, {type = "array", format = "rg16"})
local shadow_map = {
	{shadow_array, layer=1},
	{shadow_array, layer=2},
	depthstencil = g.newCanvas(w, h, {format = "depth16", readable=true})
}

local d_lights = {}
for i=0,63 do
	d_lights[i] = {
		x = rnd:random(0,w), --x
		y = rnd:random(0,h), --y
		dx = 2*(rnd:random(0,1)-.5), --dx
		dy = 2*(rnd:random(0,1)-.5), --dy
		v = rnd:random(130,170), --velocity
		s = rnd:random(140, 340), --size
	}
end

function love.update(dt)
	--move the light(s)
	local mx, my = love.mouse.getPosition()
	lights.pos:setVertex(1,{mx,my,0,300})
	--update dynamic geometry
	local e = edge
	for i, v in ipairs(dynamic_crap) do
		v.orientation = v.orientation+v.rotation*dt
		transform:reset()
		transform:translate(v.pos[1], v.pos[2])
		transform:rotate(v.orientation)
		local p1x, p1y = transform:transformPoint(-v.dimensions[1], -v.dimensions[2])
		local p2x, p2y = transform:transformPoint( v.dimensions[1], -v.dimensions[2])
		local p3x, p3y = transform:transformPoint( v.dimensions[1],  v.dimensions[2])
		local p4x, p4y = transform:transformPoint(-v.dimensions[1],  v.dimensions[2])
		set_edge(e, p1x, p1y, p2x, p2y); e = e+1
		set_edge(e, p2x, p2y, p3x, p3y); e = e+1
		set_edge(e, p3x, p3y, p4x, p4y); e = e+1
		set_edge(e, p4x, p4y, p1x, p1y); e = e+1
	end

	shadow_geometry:setDrawRange(1, 6*(e-1))

	--move the lights
	local l_pos = {0,0,0,0}
	for i,v in ipairs(d_lights) do
		v.x, v.y = v.x+v.dx*v.v*dt, v.y+v.dy*v.v*dt
		if v.x > w then v.dx = -1 end
		if v.x < 0 then v.dx = 1 end
		if v.y > h then v.dy = -1 end
		if v.y < 0 then v.dy = 1 end
		l_pos[1], l_pos[2] = v.x, v.y
		l_pos[4] = v.s
		lights.pos:setVertex(1+i, l_pos)
	end
end

g.setMeshCullMode("none")
function love.draw()
	--render the shadowmap
	g.setDepthMode("less", true)
	g.setShader(shadowmap_shader)
	g.setCanvas(shadow_map)
	g.setBlendMode("add", "premultiplied")
	g.clear()
	g.drawInstanced(shadow_geometry, lights.current_lights)
	g.setShader()
	g.setCanvas()
	g.setDepthMode("always", false)
	g.setBlendMode("alpha")

	--debug output, we do not draw the shadow,
	--instead we'll sample it during the light pass
	--g.drawLayer(shadow_map[1][1],2)
	--g.draw(shadow_map.depthstencil)

	--draw each and every light and add to the final result
	light_shader:send("shadowmap", shadow_map[1][1])
	g.setShader(light_shader)
	g.setBlendMode("add", "premultiplied")
	g.drawInstanced(lights.light, lights.current_lights)
	g.setBlendMode("alpha")
	g.setShader()

	---[[draw all the geometry
	for i,v in pairs(static_map) do
		g.translate(v.pos[1],v.pos[2])
		g.rotate(v.orientation)
		g.rectangle("line",
			-v.dimensions[1], -v.dimensions[2],
			v.dimensions[1]*2, v.dimensions[2]*2)
		g.origin()
	end

	for i,v in pairs(dynamic_crap) do
		g.translate(v.pos[1],v.pos[2])
		g.rotate(v.orientation)
		g.rectangle("line",
			-v.dimensions[1], -v.dimensions[2],
			v.dimensions[1]*2, v.dimensions[2]*2)
		g.origin()
	end
	--]]
	g.print(love.graphics.getStats( ).drawcalls, 0, 24)
	g.print(love.timer.getFPS())
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
