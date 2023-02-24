local scene = {}
local R3 = require("R3helper")
local cube = require("ciwb")

local g = love.graphics

local rng = love.math.newRandomGenerator()
function scene.draw()
	g.push()
	g.applyTransform(
		R3.translate(0,-2,0)* --move the ground
		R3.scale(10,1,10) --scale the ground
	)
	g.draw(cube) --draw the ground
	g.pop()

	rng:setSeed(31337)
	for i=1,33 do
		g.push()
		g.applyTransform(
			R3.translate(-8+16*rng:random(),-rng:random(),-8+16*rng:random()) * --move a cube
			R3.rotate(R3.aa_to_quat(0,1,0,rng:random()*math.pi*2)) * --rotate the cube
			R3.scale(.3+rng:random()*.3,1,.3+rng:random()*.5) --scale the cube
		)
		g.draw(cube) --draw the cube
		g.pop()
	end
end

return scene