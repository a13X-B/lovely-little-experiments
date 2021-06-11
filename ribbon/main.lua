local g = love.graphics
local v = require("vectoring")

local vertex_format = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"normal", "float", 2},
	{"curvature", "float", 1},
	{"VertexColor", "byte", 4}
}

local function make_chunk(s, e)
	local curve = {}
	for i = -1, e-s+1 do
		local x = i+s
		curve[#curve+1] = i*8
		curve[#curve+1] = 300+love.math.noise(x/25.1+77)*200
	end
	return curve
end

local function make_mesh(curve, l)
	local verts = {}
	l = l or 0
	for i=3, #curve-3, 2 do
		local a = v.vec2(curve[i-2], curve[i-1])
		local b = v.vec2(curve[i], curve[i+1])
		local c = v.vec2(curve[i+2], curve[i+3])
		local n1, n2 = v.cmul(b-a, v.vec2(0,1)), v.cmul(c-b, v.vec2(0,1))
		local n = v.normalize(n1+n2)
		local cur = v.dot(n1, v.normalize(c-b))
		local color = v.lerp(v.vec4(1,0,1,1), v.vec4(0,1,1,1), 0.5+cur*0.5)
		local vert = {b.x, b.y, 0, l,0, n.x,n.y, cur, color()}
		verts[#verts+1] = vert
		verts[#verts+1] = vert
		l = l + #(c-b)*0.0024
	end
	return g.newMesh(vertex_format, verts,"strip","static"), l
end

local road_s = g.newShader("road_vs.glsl","road_ps.glsl")

local noise = make_chunk(0, 100)
local mesh, l = make_mesh(noise)
local noise2 = make_chunk(100, 200)
local mesh2 = make_mesh(noise2,l)

local t = 0
function love.update(dt)
	t = t + dt
end

function love.draw()
	--g.line(noise)
	--g.setWireframe(true)
	g.setShader(road_s)
	g.draw(mesh, -400)
	g.draw(mesh2, 400)
	g.setWireframe(false)
	g.setShader()
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
