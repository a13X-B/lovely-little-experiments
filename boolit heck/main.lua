local jit = require("jit")
--jit.off()

local g = love.graphics
local rnd = love.math.newRandomGenerator(1337)
local abs = math.abs

local fdt = 1/125
local t = 0
local pause = false

local bullets_closure = {}
local bullets_oop = {}
local bullets_aos = {}
local bullets_soa = {x={}, y={}, dx={}, dy={}}

local w, h = g.getDimensions()
local n = 25000


local draw_aos
local draw_soa
local draw_oop
local draw_closure

--spawn a lot of boolit
--aos
for i = 1, n do
	local dir = rnd:random()*math.pi*2
	local v = rnd:random(2,3)*30*fdt
	bullets_aos[i] = {
		x = rnd:random()*w,
		y = rnd:random()*h,
		dx = math.cos(dir)*v,
		dy = math.sin(dir)*v,
		}
end

local function update_aos()
	for i,v in ipairs(bullets_aos) do
		do
			v.x = v.x + v.dx
			if v.x>w-3 then v.dx = -abs(v.dx) end
			if v.x < 0 then v.dx =  abs(v.dx) end
		end
		do
			v.y = v.y + v.dy
			if v.y>h-3 then v.dy = -abs(v.dy) end
			if v.y < 0 then v.dy =  abs(v.dy) end
		end
	end
end

--closure
local function new_bullet(t)
	local x = t.x
	local y = t.y
	local dx = t.dx
	local dy = t.dy
	return {
		get_x = function() return x end,
		get_y = function() return y end,
		update = function()
			do
				x = x + dx
				if x>w-3 then dx = -abs(dx) end
				if x < 0 then dx =  abs(dx) end
			end
			do
				y = y + dy
				if y>h-3 then dy = -abs(dy) end
				if y < 0 then dy =  abs(dy) end
			end
		end,
	}
end 

for i,v in ipairs(bullets_aos) do
	bullets_closure[i] = new_bullet(v)
end

local function update_closure()
	for i=1,n do
		bullets_closure[i].update()
	end
end

--oop
local bullet_prototype = {}
function bullet_prototype:update()
	do
		self.x = self.x + self.dx
		if self.x>w-3 then self.dx = -abs(self.dx) end
		if self.x < 0 then self.dx =  abs(self.dx) end
	end
	do
		self.y = self.y + self.dy
		if self.y>h-3 then self.dy = -abs(self.dy) end
		if self.y < 0 then self.dy =  abs(self.dy) end
	end
end

for i,v in ipairs(bullets_aos) do
	bullets_oop[i] = setmetatable({x=v.x, y=v.y, dx=v.dx, dy=v.dy}, {__index = bullet_prototype})
end

local function update_oop()
	for i=1,n do
		bullets_oop[i]:update()
	end
end

--soa
for i,v in ipairs(bullets_aos) do
	bullets_soa.x[i] = v.x
	bullets_soa.y[i] = v.y
	bullets_soa.dx[i] = v.dx
	bullets_soa.dy[i] = v.dy
end

local function update_soa()
	for i = 1, n do
		do
			local x = bullets_soa.x[i]
			local dx = bullets_soa.dx[i]
			x = x + dx
			if x>w-3 then bullets_soa.dx[i] = -abs(dx) end
			if x < 0 then bullets_soa.dx[i] =  abs(dx) end
			bullets_soa.x[i] = x
		end
		do
			local y = bullets_soa.y[i]
			local dy = bullets_soa.dy[i]
			y = y + dy
			if y>h-3 then bullets_soa.dy[i] = -abs(dy) end
			if y < 0 then bullets_soa.dy[i] =  abs(dy) end
			bullets_soa.y[i] = y
		end
	end
end


local samples = math.floor(w/4)
local next_sample = 1


local t_aos = {}
local t_soa = {}
local t_oop = {}
local t_closure = {}

for i=1,samples do
	t_aos[i] = 0
	t_soa[i] = 0
	t_oop[i] = 0
	t_closure[i] = 0
end
t_aos.avg = 0
t_soa.avg = 0
t_oop.avg = 0
t_closure.avg = 0


function love.update(dt)
	if pause then dt = 0 end
	t = t + dt
	while t>fdt do
		t = t -fdt
		--step aos
		t_aos[next_sample] = love.timer.getTime()
		update_aos()
		t_aos[next_sample] = love.timer.getTime() - t_aos[next_sample]
		--step oop
		t_oop[next_sample] = love.timer.getTime()
		update_oop()
		t_oop[next_sample] = love.timer.getTime() - t_oop[next_sample]
		--step closure
		t_closure[next_sample] = love.timer.getTime()
		update_closure()
		t_closure[next_sample] = love.timer.getTime() - t_closure[next_sample]
		--step soa
		t_soa[next_sample] = love.timer.getTime()
		update_soa()
		t_soa[next_sample] = love.timer.getTime() - t_soa[next_sample]

		next_sample = next_sample%samples + 1
	end
	--compute averages
	for i=1,samples do
		t_aos.avg = t_aos.avg + t_aos[i]
		t_soa.avg = t_soa.avg + t_soa[i]
		t_oop.avg = t_oop.avg + t_oop[i]
		t_closure.avg = t_closure.avg + t_closure[i]
	end
	t_aos.avg = t_aos.avg / samples
	t_soa.avg = t_soa.avg / samples
	t_oop.avg = t_oop.avg / samples
	t_closure.avg = t_closure.avg / samples
end

g.setLineStyle("rough")
g.setLineWidth(.5)
function love.draw()
	g.setColor(.2,.2,.2)
	if draw_aos then
		for i, v in ipairs(bullets_aos) do
			g.rectangle("line", v.x, v.y, 3,3)
		end
	end
	if draw_soa then
		for i = 1,n do
			g.rectangle("line", bullets_soa.x[i], bullets_soa.y[i], 3,3)
		end
	end
	if draw_oop then
		for i, v in ipairs(bullets_oop) do
			g.rectangle("line", v.x, v.y, 3,3)
		end
	end
	if draw_closure then
		for i, v in ipairs(bullets_closure) do
			g.rectangle("line", v.get_x(), v.get_y(), 3,3)
		end
	end

	--stats stuff
	--aos
	g.setColor(0,1,0)
	for i = 1, samples do
		g.line(i*4-3.5, h, i*4-3.5, h-(t_aos[i]*200000))
	end
	g.line(0, h-t_aos.avg*200000, w, h-t_aos.avg*200000)
	g.print(t_aos.avg,10,20)
	g.rectangle(draw_aos and "fill" or "line", 2, 22, 6,6)
	--soa
	g.setColor(1,0,0)
	for i = 1, samples do
		g.line(i*4-2.5, h, i*4-2.5, h-(t_soa[i]*200000))
	end
	g.line(0, h-t_soa.avg*200000, w, h-t_soa.avg*200000)
	g.print(t_soa.avg, 10, 40)
	g.rectangle(draw_soa and "fill" or "line", 2, 42, 6,6)
	--oop
	g.setColor(0,1,1)
	for i = 1, samples do
		g.line(i*4-1.5, h, i*4-1.5, h-(t_oop[i]*200000))
	end
	g.line(0, h-t_oop.avg*200000, w, h-t_oop.avg*200000)
	g.print(t_oop.avg, 10, 60)
	g.rectangle(draw_oop and "fill" or "line", 2, 62, 6,6)
	--closure
	g.setColor(0,0,1)
	for i = 1, samples do
		g.line(i*4-.5, h, i*4-.5, h-(t_closure[i]*200000))
	end
	g.line(0, h-t_closure.avg*200000, w, h-t_closure.avg*200000)
	g.print(t_closure.avg, 10, 80)
	g.rectangle(draw_closure and "fill" or "line", 2, 82, 6,6)
	
	g.setColor(0,0,0)
	g.rectangle("fill",0,0,70,20)
	g.rectangle("fill",0,h-220,70,20)
	g.rectangle("fill",0,h-420,70,20)
	g.setColor(1,1,1)
	g.line(0, h-200.5, w, h-200.5)
	g.line(0, h-400.5, w, h-400.5)
	g.line(next_sample*4-3.5, h-400, next_sample*4-3.5, h)
	g.print(love.timer.getFPS())
	g.print("1ms", 0, h-220)
	g.print("2ms", 0, h-420)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
	if k == "space" then pause = not pause end
	if k == "1" then draw_aos, draw_soa, draw_oop, draw_closure = true, false, false, false end
	if k == "2" then draw_aos, draw_soa, draw_oop, draw_closure = false, true, false, false end
	if k == "3" then draw_aos, draw_soa, draw_oop, draw_closure = false, false, true, false end
	if k == "4" then draw_aos, draw_soa, draw_oop, draw_closure = false, false, false, true end
	if k == "`" then draw_aos, draw_soa, draw_oop, draw_closure = false, false, false, false end
end
