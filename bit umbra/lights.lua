local max_lights = 64
local current_lights = 64

--math.randomseed()
local random = math.random

local lvfp = {{"lpos", "float", 4}} -- pos.xyz, scale
local lvfd = {{"diffuse", "float", 3}} -- color
local r = {math.cos(math.pi/32), math.sin(math.pi/32)}

local v = {{0,0, 0,0, 0,0,0,1}, {0,1, 0,0, 1,1,1,1}}
for i = 1, 64 do
	local t = v[#v]
	v[#v+1] = {t[1]*r[1] - t[2]*r[2], t[1]*r[2] + t[2]*r[1], 0,0, 1,1,1,1}
end

local pointlight = love.graphics.newMesh( v, nil, "static")
local pl_position = love.graphics.newMesh(lvfp, max_lights)
local pl_diffuse =  love.graphics.newMesh(lvfd, max_lights)

local w,h = love.graphics.getDimensions()

pl_position:setVertex(1, {w/2,h/2,0,66.6})
pl_diffuse:setVertex(1, {.5, .5, .5})
for i = 2, current_lights do
	pl_position:setVertex(i, {random(0, w),random(0, h),0,random(50, 350)})
	pl_diffuse:setVertex(i, {random()*.1, random()*.1, random()*.1})
end
pointlight:attachAttribute("lpos", pl_position, "perinstance")
pointlight:attachAttribute("diffuse", pl_diffuse, "perinstance")

return {
	light = pointlight,
	pos = pl_position,
	diffuse = pl_diffuse,
	max_lights = max_lights,
	current_lights = current_lights
}
