local g = love.graphics
local R3 = require("R3helper")

g.setMeshCullMode("back")
g.setFrontFaceWinding("ccw")
g.setDepthMode("less", true)

local cube = require("ciwb")

local origin = R3.new_origin(true, g.getDimensions())

love.mouse.setRelativeMode(true)
love.mouse.setGrabbed(true)

local player = {
	x = 0,
	y = 0,
	z = 0,
	hor = 0,
	ver = 0,
}

local max_ver_angle = math.pi*.25
local sens = .01
local function rotate_camera(dx,dy)
	player.hor = (player.hor+dx*sens)%(2*math.pi)
	player.ver = math.max(-max_ver_angle, math.min(max_ver_angle, player.ver + dy*sens))
end

function love.mousemoved(x, y, dx, dy)
	rotate_camera(dx, dy)
end

local velocity = 7
function love.update(dt)
	local forward, sideways = 0, 0
	if love.keyboard.isScancodeDown("w") then
		forward = 1
	end
	if love.keyboard.isScancodeDown("s") then
		forward = forward - 1
	end
	if love.keyboard.isScancodeDown("a") then
		sideways = -1
	end
	if love.keyboard.isScancodeDown("d") then
		sideways = sideways + 1
	end
	do
		local l = math.sqrt(forward*forward + sideways*sideways)
		if l ~= 0 then
			forward, sideways = forward/l, sideways/l
		end
	end
	player.z = player.z + ( sideways*math.sin(player.hor) - forward*math.cos(player.hor) )*dt*velocity
	player.x = player.x - ( sideways*math.cos(player.hor) + forward*math.sin(player.hor) )*dt*velocity
end

local rng = love.math.newRandomGenerator()
function love.draw()
	local t = love.timer.getTime()
	g.setDepthMode("less", true)
	g.replaceTransform(origin)
	g.applyTransform(
		R3.rotate(R3.aa_to_quat(1,0,0,player.ver)) * --rotate the camera
		R3.rotate(R3.aa_to_quat(0,1,0,player.hor)) * --rotate the camera
		R3.translate(player.x, player.y, player.z) --move the camera
	)

	g.push()
	g.applyTransform(
		R3.translate(0,-2,0) * --move the ground
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

	g.origin()
	g.setDepthMode("always", false)
	g.print(love.timer.getDelta())
	g.print(g.getStats().drawcalls, 0, 20)
	g.print(love.timer.getFPS(), 0, 40)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
