local g = love.graphics
local R3 = require("R3helper")

g.setMeshCullMode("back")
g.setFrontFaceWinding("ccw")

local texture = g.newImage("brick.png", {mipmaps=true})
local cube = require("ciwb")
cube:setTexture(texture)

local origin = R3.new_origin(true, g.getDimensions())

function love.draw()
	local t = love.timer.getTime()
	g.setDepthMode("less", true)
	g.replaceTransform(
		origin *
		R3.translate(0,0,2.5) * --step away a little bit
		R3.rotate(R3.aa_to_quat(math.cos(t), math.sin(t), 0, t%(math.pi*2))) --rotate the cube
	)

	g.draw(cube)
	g.origin()
	g.setDepthMode("always", false)
	g.print(love.timer.getDelta())
	g.print(g.getStats().drawcalls, 0, 20)
	g.print(love.timer.getFPS(), 0, 40)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
