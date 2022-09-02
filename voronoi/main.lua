local g = love.graphics

--cell parameters
local radius = 256
--sim parameters
local animate = false

--our future texture and its tiling
local v_size = 512
local voronoi = g.newCanvas(v_size,v_size,{msaa=8})
voronoi:setWrap("repeat","repeat")
local w,h = g.getDimensions()
local tiling = g.newQuad(0,0,w,h,voronoi)

--meshes for different metrics
local vfp = {{"VertexPosition","float", 3}}
local vft = {{"VertexTexCoord","float", 2}}
local vfc = {{"VertexColor","float", 4}}

local l1={}
local l2={}
local lmax={}

--l2 mesh
do
	local vertices = {{0,0,9}}
	local uv = {{.5,.5}}
	local color_radial = {{0,0,0,1}}
	local color_solid = {{1,1,1,1}}
	local a,i = math.cos(2*math.pi/360), math.sin(2*math.pi/360)
	local x,y = radius, 0
	for j=1,361 do
		vertices[#vertices+1] = {x,y,0}
		uv[#uv+1] = {(x+radius)/(2*radius),(y+radius)/(2*radius)}
		color_radial[#color_radial+1] = {1,1,1,1}
		color_solid[#color_solid+1] = {1,1,1,1}
		x,y = x*a - y*i, x*i + y*a
	end
	l2.uv = g.newMesh(vft, uv, "fan", "static")
	l2.mesh = g.newMesh(vfp, vertices, "fan", "static")
	l2.solid = g.newMesh(vfc, color_solid, "fan", "static")
	l2.radial = g.newMesh(vfc, color_radial, "fan", "static")
	l2.mesh:attachAttribute("VertexColor", l2.solid)
end

--l1 mesh
do
	local vertices = {{0,0,9}}
	local uv = {{.5,.5}}
	local color_radial = {{0,0,0,1}}
	local color_solid = {{1,1,1,1}}
	local x,y = radius, 0
	for j=1,5 do
		vertices[#vertices+1] = {x,y,0}
		uv[#uv+1] = {(x+radius)/(2*radius),(y+radius)/(2*radius)}
		color_radial[#color_radial+1] = {1,1,1,1}
		color_solid[#color_solid+1] = {1,1,1,1}
		x,y = -y, x
	end
	l1.uv = g.newMesh(vft, uv, "fan", "static")
	l1.mesh = g.newMesh(vfp, vertices, "fan", "static")
	l1.solid = g.newMesh(vfc, color_solid, "fan", "static")
	l1.radial = g.newMesh(vfc, color_radial, "fan", "static")
	l1.mesh:attachAttribute("VertexColor", l1.solid)
end

--lmax mesh
do
	local vertices = {{0,0,9}}
	local uv = {{.5,.5}}
	local color_radial = {{0,0,0,1}}
	local color_solid = {{1,1,1,1}}
	local x,y = radius, radius
	for j=1,5 do
		vertices[#vertices+1] = {x,y,0}
		uv[#uv+1] = {(x+radius)/(2*radius),(y+radius)/(2*radius)}
		color_radial[#color_radial+1] = {1,1,1,1}
		color_solid[#color_solid+1] = {1,1,1,1}
		x,y = -y, x
	end
	lmax.uv = g.newMesh(vft, uv, "fan", "static")
	lmax.mesh = g.newMesh(vfp, vertices, "fan", "static")
	lmax.solid = g.newMesh(vfc, color_solid, "fan", "static")
	lmax.radial = g.newMesh(vfc, color_radial, "fan", "static")
	lmax.mesh:attachAttribute("VertexColor", lmax.solid)
end

local metric = l2.mesh

--seed points
local step = 512/8
local seeds = {}
local dirs = {}
local colors = {}
for i = 0, 7 do
	for j = 0, 7 do
		seeds[#seeds+1] = {(i+math.random())*step,(j+math.random())*step}
		dirs[#dirs+1] = {math.random()-.5,math.random()-.5,10+math.random()*50}
		colors[#colors+1] = {math.random(),math.random(),math.random()}
	end
end

--render voronoi texture
local canvas_setup = {voronoi, depth=true}
local function update_voronoi(dt)
	g.setCanvas(canvas_setup)
	g.clear()
	g.setDepthMode("less", true)
	--animation
	if animate then
		for i,v in ipairs(seeds) do
			v[1] = (v[1] + dirs[i][1]*dirs[i][3]*dt)%v_size
			v[2] = (v[2] + dirs[i][2]*dirs[i][3]*dt)%v_size
		end
	end
	--tiling
	for i = -v_size,v_size,v_size do
		for j = -v_size,v_size,v_size do
			for k,v in ipairs(seeds) do
				g.setColor(colors[k])
				g.draw(metric,v[1]+i,v[2]+j,0,1,1,128,128)
			end
		end
	end
	g.setDepthMode("always", false)
	g.setCanvas()
end

function love.draw()
	update_voronoi(love.timer.getDelta())
	--g.draw(voronoi,0,0)
	g.draw(voronoi, tiling, 0,0)
	g.setColor(1,1,1)
	g.print("1,2,3 for different metrics")
	g.print("q,w for different fills", 0, 20)
	g.print("e - toggle animation", 0, 40)
	g.print("r - generate new colors", 0, 60)
end

function love.keypressed(k,s,r)
	if k == "1" then metric = l1.mesh end
	if k == "2" then metric = l2.mesh end
	if k == "3" then metric = lmax.mesh end
	if k == "q" then
		l1.mesh:attachAttribute("VertexColor", l1.solid)
		l2.mesh:attachAttribute("VertexColor", l2.solid)
		lmax.mesh:attachAttribute("VertexColor", lmax.solid)
	end
	if k == "w" then
		l1.mesh:attachAttribute("VertexColor", l1.radial)
		l2.mesh:attachAttribute("VertexColor", l2.radial)
		lmax.mesh:attachAttribute("VertexColor", lmax.radial)
	end
	if k == "e" then animate = not animate end
	if k == "r" then
		colors = {}
		for i = 0, 7 do
			for j = 0, 7 do
				colors[#colors+1] = {math.random(),math.random(),math.random()}
			end
		end
	end
	if k == "escape" then love.event.quit(0) end
end
