local g = love.graphics

local lights = require("lights")
local w,h = love.graphics.getDimensions()

local static_map = {}
local dynamic_crap = {}

local light_shader = g.newShader("light_shader.glsl")
local shadowmap_shader = g.newShader("shadow_map.glsl")

local rnd= love.math.newRandomGenerator(1337)

--generate static geometry
--a bunch of randomly placed and oriented rectangles
for i=1,13 do
	static_map[i] = {
		pos = {rnd:random(0,w), rnd:random(0,h)},
		dimensions = {rnd:random(20,100), 10},--half dimensions
		orientation = rnd:random()*math.pi,
	}
end

--TODO: generate dynamic geometry

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
shadow_geometry:setDrawRange(1, 6*(edge-1))

local shadow_map = {
	g.newCanvas(w, h, {format = "rg16"}),
	--g.newCanvas(w, h, {format = "rg16"}),
	depthstencil = g.newCanvas(w, h, {format = "depth16", readable=true})
}

function love.update(dt)
	--move the light(s)
	local mx, my = love.mouse.getPosition()
	lights.pos:setVertex(1,{mx,my,0,300})
	--update dynamic geometry
	shadow_geometry:setDrawRange(1, 6*(edge-1))
end

g.setMeshCullMode("none")
function love.draw()
	--render the shadowmap
	g.setDepthMode("less", true)
	g.setShader(shadowmap_shader)
	g.setCanvas(shadow_map)
	g.clear()
	g.drawInstanced(shadow_geometry, 1)
	g.setShader()
	g.setCanvas()
	g.setDepthMode("always", false)

	--debug output, we do not draw the shadow,
	--instead we'll sample it during the light pass
	g.draw(shadow_map[1])
	--g.draw(shadow_map.depthstencil)

	--draw each and every light and add to the final result
	g.setShader(light_shader)
	g.setBlendMode("add", "premultiplied")
	g.drawInstanced(lights.light, lights.current_lights)
	g.setBlendMode("alpha")
	g.setShader()

	--draw all the geometry
	for i,v in pairs(static_map) do
		g.translate(v.pos[1],v.pos[2])
		g.rotate(v.orientation)
		g.rectangle("line",
			-v.dimensions[1], -v.dimensions[2],
			v.dimensions[1]*2, v.dimensions[2]*2)
		g.origin()
	end
	love.graphics.print(love.timer.getFPS())
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
