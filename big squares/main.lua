local g = love.graphics
local w, h = g.getDimensions()

local screen = g.newImage("screen.png")
screen:setFilter("nearest")
local sw, sh = screen:getDimensions()
local smesh = g.newMesh(sw*sh*6, "triangles", "static")
for y = 0, sh-1 do
	for x = 0, sw-1 do
		local i = (sw*y+x)*6
		local hpu,hpv = .5/sw, .5/sh
		local u,v = x/(sw-1), y/(sh-1)
		smesh:setVertex(i+1, x,   y,   u,v)
		smesh:setVertex(i+2, x,   y+1, u,v)
		smesh:setVertex(i+3, x+1, y,   u,v)
		smesh:setVertex(i+4, x,   y+1, u,v)
		smesh:setVertex(i+5, x+1, y+1, u,v)
		smesh:setVertex(i+6, x+1, y,   u,v)
	end
end
smesh:setTexture(screen)

local s = math.min(w/sw, h/sh)

function love.draw()
	g.scale(s)
	g.draw(smesh)
	g.origin()
	g.print(love.timer.getFPS())
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
