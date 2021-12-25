local m = love.math
local g = love.graphics

local projection = m.newTransform()
local inverse = m.newTransform()
local last_one
local tmp = m.newTransform()

local R3 = {}

function R3.newProjection(perspective, width, height, hfov)
	local p = perspective and 1 or 0
	projection:setMatrix(
		1, 0, 0, 0,
		0, width/height, 0, 0,
		0, 0, 1, -1,
		0, 0, p, 1
	)
	inverse:setMatrix(
		2/width,0,0,-1,
		0,-2/height,0,1,
		0,0,-1/10,0,
		0,0,0,1
	)
	last_one = inverse:inverse():apply(projection)
	return last_one
end

function R3.origin(projection)
	g.replaceTransform(projection or last_one)
end

function R3.translate(x,y,z)
	tmp:setMatrix(
		1,0,0,x,
		0,1,0,y,
		0,0,1,z,
		0,0,0,1
	)
	g.applyTransform(tmp)
	tmp:reset()
end

function R3.rotate(i,j,k,w)
	tmp:setMatrix(
		1-2*j*j-2*k*k, 2*i*j+2*w*k, 2*i*k-2*w*j, 0,
		2*i*j-2*w*k, 1-2*i*i-2*k*k, 2*j*k+2*w*i, 0,
		2*i*k+2*w*j, 2*j*k-2*w*i, 1-2*i*i-2*j*j, 0,
		0, 0, 0, 1
	)
	g.applyTransform(tmp)
	tmp:reset()
end

function R3.scale(x,y,z)
	tmp:setMatrix(
		x,0,0,0,
		0,y,0,0,
		0,0,z,0,
		0,0,0,1
	)
	g.applyTransform(tmp)
	tmp:reset()
end

return R3