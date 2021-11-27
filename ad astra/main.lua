local g = love.graphics

local seed = love.math.random()
local rnd = love.math.newRandomGenerator()
rnd:setSeed(seed)

--stuff for a canvas based starfield
local w, h = g.getDimensions()
local sfq = g.newQuad(0,0,w,h,w,h)
local sfq2 = g.newQuad(0,0,w,h,w,h)
local sf = g.newCanvas(w,h)
sf:setWrap("repeat")
g.setCanvas(sf)

local n = 1337
for i=1,n do
	local x,y = rnd:random(w), rnd:random(h)
	g.rectangle("fill", x, y, 1,1)
end
g.setCanvas()


local star_mesh = g.newMesh(n*4, "points")

local offsets = {{0,0},{w,0},{0,h},{w,h}}

for j=1,4 do
	rnd:setSeed(seed)
	for i=1,1337 do
		local x,y = rnd:random(w) - offsets[j][1], rnd:random(h) - offsets[j][2]
		star_mesh:setVertex( (j-1)*n+i, x, y, 0, 0, 1, 1, 1, 1 )
	end
end


function love.draw()
	--[[canvas based starfield
	sfq:setViewport(love.timer.getTime()*33%w, love.timer.getTime()*15%h, w,h)
	sfq2:setViewport((-love.timer.getTime()*35)%w, (-love.timer.getTime()*20)%h, w,h)
	g.draw(sf,sfq)
	g.draw(sf,sfq2,w,h,0,-1,-1)
	--]]
	g.draw(star_mesh,w-love.timer.getTime()*33%w, h-love.timer.getTime()*15%h)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
