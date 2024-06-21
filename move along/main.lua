local g = love.graphics
local w, h = g.getDimensions()
local cr = require"catmull_rom"
local derp = cr.newSpline({100,100,200,100,150,300})

local b2cp = {w*.55, h*.45, w*.75, h*.05, w*.95, h*.45}
local b3cp = {w*.55, h*.95, w*.55, h*.05, w*.95, h*1.5, w*.95, h*.55}
local crcp = {
	w*.2, h*.5,
	w*.1, h*.1,
	w*.4, h*.1,
	w*.3, h*.4,
	w*.4, h*.9,
	w*.1, h*.7,
	w*.2, h*.6,
}

local function lerp(a,b,t)
	return a*(1-t)+b*t
end

local b2 = love.math.newBezierCurve(b2cp)
local b3 = love.math.newBezierCurve(b3cp)
local cat = cr.newSpline(crcp)

local lines = {b2:render(), b3:render(), cat:render(1)}
local len = {}

for j,v in ipairs(lines) do
	local l = {}
	for i=1,#v-3,2 do
		local dx,dy = v[i], v[i+1]
		dx,dy = v[i+2]-dx,v[i+3]-dy
		l[#l+1] = math.sqrt(dx*dx+dy*dy)
	end
	len[j] = l
end

local p = {{s=1, dr=0},{s=1, dr=0},{s=1, dr=0}} -- current segment, distance remainder

function love.update(dt)
	for i,v in ipairs(p) do
		v.dr = v.dr + 100*dt
		while v.dr > len[i][v.s] do
			v.dr = v.dr - len[i][v.s]
			if v.s + 1 > #len[i] then v.s = 1 else v.s = v.s + 1 end
		end
	end
end


function love.draw()
	for i,v in ipairs(p) do
		g.line(lines[i])
	end
	for i,v in ipairs(p) do
		local sx, sy = lines[i][v.s*2-1], lines[i][v.s*2]
		local ex, ey = lines[i][v.s*2+1], lines[i][v.s*2+2]
		local t = v.dr/len[i][v.s]
		x = lerp(sx, ex, t)
		y = lerp(sy, ey, t)
		g.circle("line",x,y, 10)
	end
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
