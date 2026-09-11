local g = love.graphics
require("table.new")

local n = 99999

math.randomseed(love.timer.getTime())

local x = table.new(n,0)
local y = table.new(n,0)

-- box muller transform
local function normal_bm()
	local phi = math.random()*2*math.pi
	local r = math.sqrt(-2*math.log(1-math.random()))
	return math.cos(phi)*r, math.sin(phi)*r
end

-- bhaskara trig approx
local function sincos(x) -- [0..2] -> sincos(0..2pi)
	local si = ((x + 0.5)%1)*2.0 - 1.0
	local cx = 20.0 / (si*si + 4.0) - 4.0
	local cy = math.sqrt(1.0 - cx*cx)
	local cs, ss = (0.5-((0.25+x*0.5)%1)), (0.5-(x*0.5%1))
	cs, ss = cs/math.abs(cs), ss/math.abs(ss)
	assert(cs==cs, "cs is 0") -- if those ever assert
	assert(ss==ss, "ss is 0") -- a better sign is needed
	return cy*ss, cx*cs
end

-- box muller with trig approximation
local function normal_bma()
	local s,c = sincos(math.random()*2)
	local r = math.sqrt(-2*math.log(1-math.random()))
	return c*r, s*r
end

local sampn = 0x10000
local lut = table.new(sampn,0)
for i=1,sampn,2 do
	lut[i],lut[i+1] = normal_bm()
end

local function normal_lut()
	return lut[math.random(sampn)], lut[math.random(sampn)]
end

local t = 0
local w,h = g.getDimensions()

function love.update(dt)
	t = love.timer.getTime()
	for i = 1,n do
		x[i], y[i] = normal_lut()
	end
	t = love.timer.getTime()-t
end

local sigma = 100
function love.draw()
	g.setBlendMode("alpha")
	g.setColor(1,1,1,1)
	g.print(t,0,0)
	g.translate(w/2,h/2)
	g.setColor(1,1,1,.25)
	g.circle("line",0,0,sigma)
	g.circle("line",0,0,2*sigma)
	g.circle("line",0,0,3*sigma)

	g.setBlendMode("add", "premultiplied")
	g.setColor(.01,.01,.01,.01)
	for i=1,n do
		g.circle("fill", x[i]*sigma, y[i]*sigma, 3)
	end
end

function love.keypressed(k,s,r)
  if s == "escape" then love.event.quit() end
end
