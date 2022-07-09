local g = love.graphics

local lights = require("lights")
local w,h = love.graphics.getDimensions()

local static_map = {}
local dynamic_crap = {}

local light_shader = g.newShader("light_shader.glsl")
local shadowmap_shader = g.newShader("shadow_map.glsl")

local rnd= love.math.newRandomGenerator(1337)

for i=1,13 do
	static_map[i] = {
		pos = {rnd:random(0,w), rnd:random(0,h)},
		dimensions = {rnd:random(40,200), 20},
		orientation = rnd:random()*math.pi,
	}
end

local max_edges = 10000
local shadow_vf = {{"VertexPosition", "float", 3}}
local shadow_geometry = g.newMesh(shadow_vf, max_edges*6, "triangles", "stream")
shadow_geometry:attachAttribute("lpos", lights.pos, "perinstance")


local transform = love.math.newTransform()
local vi = 1
for i, v in ipairs(static_map) do
	transform:reset()
	transform:translate(v.pos[1], v.pos[2])
	transform:rotate(v.orientation)
	local p1x, p1y = transform:transformPoint(-v.dimensions[1]/2, -v.dimensions[2]/2)
	local p2x, p2y = transform:transformPoint( v.dimensions[1]/2, -v.dimensions[2]/2)
	local p3x, p3y = transform:transformPoint( v.dimensions[1]/2,  v.dimensions[2]/2)
	local p4x, p4y = transform:transformPoint(-v.dimensions[1]/2,  v.dimensions[2]/2)
	shadow_geometry:setVertex(vi, {p1x,p1y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p1x,p1y,1}); vi = vi+1
	shadow_geometry:setVertex(vi, {p2x,p2y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p2x,p2y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p2x,p2y,1}); vi = vi+1
	shadow_geometry:setVertex(vi, {p1x,p1y,1}); vi = vi+1

	shadow_geometry:setVertex(vi, {p2x,p2y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p2x,p2y,1}); vi = vi+1
	shadow_geometry:setVertex(vi, {p3x,p3y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p3x,p3y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p3x,p3y,1}); vi = vi+1
	shadow_geometry:setVertex(vi, {p2x,p2y,1}); vi = vi+1
	
	shadow_geometry:setVertex(vi, {p3x,p3y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p3x,p3y,1}); vi = vi+1
	shadow_geometry:setVertex(vi, {p4x,p4y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p4x,p4y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p4x,p4y,1}); vi = vi+1
	shadow_geometry:setVertex(vi, {p3x,p3y,1}); vi = vi+1
	
	shadow_geometry:setVertex(vi, {p4x,p4y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p4x,p4y,1}); vi = vi+1
	shadow_geometry:setVertex(vi, {p1x,p1y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p1x,p1y,0}); vi = vi+1
	shadow_geometry:setVertex(vi, {p1x,p1y,1}); vi = vi+1
	shadow_geometry:setVertex(vi, {p4x,p4y,1}); vi = vi+1
end

shadow_geometry:setDrawRange(1, vi-1)

g.setMeshCullMode("none")
function love.draw()
	love.graphics.print(love.timer.getFPS())
	g.setShader(light_shader)
	g.setBlendMode("add", "premultiplied")
	g.drawInstanced(lights.light, lights.current_lights)
	g.setBlendMode("alpha")
	g.setShader()
	
	g.setShader(shadowmap_shader)
	g.drawInstanced(shadow_geometry, 1)
	g.setShader()
	
	for i,v in pairs(static_map) do
		g.translate(v.pos[1],v.pos[2])
		g.rotate(v.orientation)
		g.rectangle("line",
			-v.dimensions[1]/2, -v.dimensions[2]/2,
			v.dimensions[1], v.dimensions[2])
		g.origin()
	end
end

function love.update(dt)
	local mx, my = love.mouse.getPosition()
	lights.pos:setVertex(1,{mx,my,0,300})
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
