local g = love.graphics

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

return cube