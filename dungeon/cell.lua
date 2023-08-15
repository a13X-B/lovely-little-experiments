local g = love.graphics

local vcf = {{"VertexPosition", "float", 3}}
local vtf = {{"VertexTexCoord", "float", 2}}
local vt = {
	{0,0}, {1,0}, {0,1}, {1,1}
}

local vm = {
	1,3,2, 2,3,4,
}

local uv = g.newMesh(vtf, vt, "triangles", "static")

local floor_tx = g.newImage("floor.png",{mipmaps=true})
local ceil_tx = g.newImage("ceil.png",{mipmaps=true})
local wall_tx = g.newImage("wall.png",{mipmaps=true})

local floor = g.newMesh(vcf,
	{{-1,-1,-1}, {1,-1,-1}, {-1,-1,1}, {1,-1,1}},
	"triangles", "static")
floor:attachAttribute("VertexTexCoord", uv)
floor:setVertexMap(vm)
floor:setTexture(floor_tx)

local ceil = g.newMesh(vcf,
	{{-1,1,-1}, {1,1,-1}, {-1,1,1}, {1,1,1}},
	"triangles", "static")
ceil:attachAttribute("VertexTexCoord", uv)
ceil:setVertexMap(vm)
ceil:setTexture(ceil_tx)

local left = g.newMesh(vcf,
	{{-1,-1,-1}, {-1,-1,1}, {-1,1,-1}, {-1,1,1}},
	"triangles", "static")
left:attachAttribute("VertexTexCoord", uv)
left:setVertexMap(vm)
left:setTexture(wall_tx)

local front = g.newMesh(vcf,
	{{-1,-1,-1}, {1,-1,-1}, {-1,1,-1}, {1,1,-1}},
	"triangles", "static")
front:attachAttribute("VertexTexCoord", uv)
front:setVertexMap(vm)
front:setTexture(wall_tx)

return {
	draw = function(id)
		if id == 0 then return end
		g.draw(ceil)
		g.draw(floor)
		if id%2 == 0 then
			g.draw(left)
		end
		if id > 2 then
			g.draw(front)
		end
	end
}
