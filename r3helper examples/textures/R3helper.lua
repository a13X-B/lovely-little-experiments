local m = love.math
local g = love.graphics

local tmp = m.newTransform()

local R3 = {}

function R3.new_inverse(width, height)
	return m.newTransform():setMatrix(
		2/width,0,0,-1,
		0,-2/height,0,1,
		0,0,-1/10,0,
		0,0,0,1
	):inverse()
end

function R3.new_projection(perspective, width, height, hfov)
	local p = perspective and 1 or 0
	hfov = hfov or math.pi*.5
	local f = 1/math.tan(hfov*.5)
	return m.newTransform():setMatrix(
		1*f, 0, 0, 0,
		0, f*width/height, 0, 0,
		0, 0, 1, -1,
		0, 0, p, 0
	)
end

function R3.new_origin(perspective, width, height, hfov)
	return R3.new_inverse(width, height):apply(R3.new_projection(perspective, width, height, hfov))
end

function R3.set(transform)
	g.replaceTransform(transform)
end

function R3.apply(transform)
	g.applyTransform(transform)
end

function R3.translate(x,y,z)
	return tmp:setMatrix(
		1,0,0,x,
		0,1,0,y,
		0,0,1,z,
		0,0,0,1
	)
end

function R3.scale(x,y,z)
	return tmp:setMatrix(
		x,0,0,0,
		0,y,0,0,
		0,0,z,0,
		0,0,0,1
	)
end

function R3.rotate(i,j,k,w)
	return tmp:setMatrix(
		1-2*j*j-2*k*k, 2*i*j+2*w*k, 2*i*k-2*w*j, 0,
		2*i*j-2*w*k, 1-2*i*i-2*k*k, 2*j*k+2*w*i, 0,
		2*i*k+2*w*j, 2*j*k-2*w*i, 1-2*i*i-2*j*j, 0,
		0, 0, 0, 1
	)
end

function R3.aa_to_quat(x,y,z,a)
	--let's turn axis angle into a quaternion
	local l = math.sqrt(x*x+y*y+z*z)
	x,y,z = x/l, y/l, z/l --normalize imaginary part
	local w, s = math.cos(a/2), math.sin(a/2) --the real part is a COsine of half an angle
	--the imaginary part will get multiplied by sine of half an angle
	return x*s, y*s, z*s, w
end

return R3
