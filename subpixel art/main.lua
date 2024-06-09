local g = love.graphics
local m = love.math
g.setDefaultFilter("nearest")
local img = g.newImage("derp.png")
local w,h = g.getDimensions()
local q = m.linearToGamma(1/4,0,0)
local s = 4 -- upscale value
local bleed, hint = false, true

local color = {4,4,4}

local pixel = g.newCanvas(s,s)
pixel:setWrap("repeat","repeat")

local stq = g.newQuad(0,0,w,h,pixel)

function love.draw()
	local sw,sh = g.getDimensions()
	-- add up the same picture with offsets to get light bleeding effect if needed
	g.setBlendMode("add", "premultiplied")
	if bleed then
		g.setColor(q,q,q)
		g.draw(img,1,0,0,s,s)
		g.draw(img,0,1,0,s,s)
		g.draw(img,1,1,0,s,s)
	end
	g.draw(img,0,0,0,s,s)

	-- multiply the entire screen by pixel pattern
	g.setColor(1,1,1)
	g.setBlendMode("multiply", "premultiplied")
	g.draw(pixel, stq)

	-- ui stuff, you shouldn't care about it, I sure didn't
	g.setBlendMode("replace", "premultiplied")
	g.draw(pixel, w-20*s,0,0,20,20)
	g.setBlendMode("alpha")
	g.setColor(0,0,0)
	g.rectangle("fill", w-20*s, 20*s, 20*s, 60)
	g.setColor(1,1,1)
	g.rectangle("line", w-20*s,0,20*s,20*s)
	g.print("r: "..(color[1]/4),w-20*s,20*s)
	g.print("g: "..(color[2]/4),w-20*s,20*s+20)
	g.print("b: "..(color[3]/4),w-20*s,20*s+40)
	if hint then
		g.print("press h to hide this hint", 300, 20)
		g.print("press space to toggle light bleeding", 300, 40)
		g.print("left click to add and right click to subtract the color from the top right minicanvas", 300, 60)
		g.print("press 1,2,3 to cycle r,g, and b components of the color", 300, 80)
	end
end

local modes = {"add", "subtract"}
function love.mousepressed(x,y,b)
	g.setCanvas(pixel)
	g.setBlendMode(modes[b] or "add", "premultiplied")
	local cr,cg,cb = m.linearToGamma(color[1]/4,color[2]/4,color[3]/4)
	g.setColor(m.linearToGamma(color[1]/4,color[2]/4,color[3]/4))
	local cx, cy = math.floor((x - (w-20*s))/20), math.floor(y/20)
	g.rectangle("fill",cx,cy,1,1)
	g.setCanvas()
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
	local id = tonumber(k)
	if color[id] then color[id] = (color[id]+1)%5 end
	if k == "h" then hint = not hint end
	if k == "space" then bleed = not bleed end
end
