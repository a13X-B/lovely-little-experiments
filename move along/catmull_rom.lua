local spline = {}

local function knot(t,a, ax,ay, bx,by)
	return t + ((bx-ax)*(bx-ax) + (by-ay)*(by-ay))^(.5*a)
end

function spline:evaluate(i, t, alpha, loop)
	local np = self:getControlPointCount()
	local x0,y0,x1,y1,x2,y2,x3,y3
	if loop then
		assert(np >= 3, "need at least 3 control points for looping spline")
		x0,y0 = self:getControlPoint(1+((i-2)%np))
		x1,y1 = self:getControlPoint(1+((i-1)%np))
		x2,y2 = self:getControlPoint(1+((i)%np))
		x3,y3 = self:getControlPoint(1+((i+1)%np))
	else
		assert(np>3, "need at least 4 control points")
		assert(i>1, "first segment can't be evaluated in non-looping mode")
		assert(i<np-1, "last segment can't be evaluated in non-looping mode")
		x0,y0 = self:getControlPoint(i-1)
		x1,y1 = self:getControlPoint(i)
		x2,y2 = self:getControlPoint(i+1)
		x3,y3 = self:getControlPoint(i+2)
	end
	local t1 = knot(0,alpha,x0,y0,x1,y1)
	local t2 = knot(t1,alpha,x1,y1,x2,y2)
	local t3 = knot(t2,alpha,x2,y2,x3,y3)
	t = t1*(1-t)+t2*t
	local a1x, a1y = (t1-t)/t1*x0 + t/t1*x1, (t1-t)/t1*y0 + t/t1*y1
	local a2x, a2y = (t2-t)/(t2-t1)*x1 + (t-t1)/(t2-t1)*x2, (t2-t)/(t2-t1)*y1 + (t-t1)/(t2-t1)*y2
	local a3x, a3y = (t3-t)/(t3-t2)*x2 + (t-t2)/(t3-t2)*x3, (t3-t)/(t3-t2)*y2 + (t-t2)/(t3-t2)*y3
	local b1x, b1y = (t2-t)/t2*a1x + t/t2*a2x, (t2-t)/t2*a1y + t/t2*a2y
	local b2x, b2y = (t3-t)/(t3-t1)*a2x + (t-t1)/(t3-t1)*a3x, (t3-t)/(t3-t1)*a2y + (t-t1)/(t3-t1)*a3y
	return (t2-t)/(t2-t1)*b1x + (t-t1)/(t2-t1)*b2x, (t2-t)/(t2-t1)*b1y + (t-t1)/(t2-t1)*b2y
end

function spline:getControlPoint(i)
	return self.control_points[2*i-1], self.control_points[2*i]
end

function spline:getControlPointCount()
	return #self.control_points/2
end

function spline:insertControlPoint(x,y,i)
	i = i or 1 + #self.control_points/2
	for j = i, 1 + #self.control_points/2 do
		self.control_points[j*2-1], x = x, self.control_points[j*2-1]
		self.control_points[j*2], y = y, self.control_points[j*2]
	end
end

function spline:removeControlPoint(i)
	for j=i, #self.control_points/2 do
		self.control_points[j*2-1] = self.control_points[j*2+1]
		self.control_points[j*2] = self.control_points[j*2+2]
	end
end

function spline:setControlPoint(i, x, y)
	self.control_points[i*2-1] = x
	self.control_points[i*2] = y
end

function spline:render(alpha, loop, segments)
	alpha, segments = alpha or .5, segments or 20
	local first = loop and 1 or 2
	local last = self:getControlPointCount()
	if not loop then last = last-2 end
	local line = {}
	for i = first,last do
		for t = 0,segments-1 do
			line[#line+1], line[#line+2] = self:evaluate(i,t/segments,alpha,loop)
		end
	end
	line[#line+1], line[#line+2] = self:evaluate(last,1,alpha,loop)
	return line
end

local spline_mt = {__index = spline}

local function newSpline(x,y,...)
	local cp
	if type(x) == "table" then
		cp = {}
		for i=1,#x do cp[i] = x[i] end
	else
		cp = {x,y,...}
	end
	return setmetatable({control_points = cp}, spline_mt)
end

return {
	newSpline = newSpline,
}