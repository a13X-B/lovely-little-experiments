local g = love.graphics

local cell = require("cell")
local R3 = require("R3helper")

-- map is a 2d array
-- upprer walkable is 1, left wall is 2, upper wall is 3, both walls is 4
-- right and down walls are adjacent tile's left and upper
-- requires an additional row/column of tiles
local map = {
	{0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0},
	{0,0,4,3,2,0,0,0},
	{0,0,2,1,3,2,0,0},
	{0,0,3,2,2,2,0,0},
	{0,0,0,2,1,2,0,0},
	{0,0,0,3,3,0,0,0},
	{0,0,0,0,0,0,0,0},
}

local player = {
	pos={4,4}, -- current position
	goal=nil, -- (not so) final destination
	midgoal=nil, -- for smoothly bumping into walls
	moving = 0, -- moving timer
	dir = 0, -- 0 is up, 1 is right and so on
	wishdir = 0
}
local movetime = .4 -- movetime constant

function love.update(dt)
	if player.moving > 0 then
		player.moving = math.max(player.moving - dt,0) -- tick down the move clock
	end
	if player.moving == 0 then
		if player.wishdir ~= player.dir then
			player.dir = player.wishdir % 4
			player.wishdir = player.dir
		end
		if player.goal then -- if we had the goal and the timer finished
			player.pos = player.goal -- put player at the goal position
			player.goal, player.midgoal = nil, nil -- create garbage so collector doesn't get paid for nothing
		end
	end
end

--g.setMeshCullMode("none")
g.setFrontFaceWinding("ccw")

local origin = R3.new_origin(true, g.getDimensions())

local path = love.math.newBezierCurve(0,0,0,0,0,0) -- three point curve for movement rendering
function love.draw()
	-- since the movement timer ticking back the final and starting position are swapped
	path:setControlPoint(1, unpack(player.goal or player.pos))
	path:setControlPoint(2, unpack(player.midgoal or player.pos))
	path:setControlPoint(3, unpack(player.pos))
	local x, y = path:evaluate(player.moving / movetime)
	local dir = player.wishdir + (player.moving / movetime)*(player.dir - player.wishdir)
	g.setDepthMode("less", true)
	g.replaceTransform(
		origin
	)
	g.applyTransform(
		R3.scale(1,1,-1)* -- map is upside down so
		R3.rotate(R3.aa_to_quat(0,1,0,-dir*math.pi/2))* --rotate to face the proper direction
		R3.translate(-x,0,-y)
	)
	--g.applyTransform(R3.scale(1,1,-1))
	for j,r in ipairs(map) do
		for i,id in ipairs(r) do
			if id ~= 0 then
				local x, y = path:evaluate(player.moving / movetime)
				local c = 1/(1+(x-i)^2 + (y-j)^2)
				g.setColor(c,c,c) -- add some cheap depth
				g.push()
				g.applyTransform(R3.translate(i,0,j)*R3.scale(.5,.5,.5))
				cell.draw(id)
				g.pop()
			end
		end
	end
	g.origin()
	g.setColor(1,1,1)
	g.setDepthMode("always", false)
	g.origin()
	g.print(love.timer.getFPS())
	--g.print(player.pos[1].." "..player.pos[2], 0, 20)
end

local mv = { -- move vector
	{0,-1},
	{1, 0},
	{0, 1},
	{-1,0},
}
local function move(relativedir)
	local dir_id = ((player.dir + relativedir)%4)+1
	local px, py = player.pos[1], player.pos[2]
	local gx, gy = mv[dir_id][1], mv[dir_id][2]
	player.midgoal = {px+gx/2, py+gy/2}
	local goal = map[py+gy][px+gx]
	local current = map[py][px]
	local can_move
	if gx < 0 then
		can_move = goal ~=0 and current ~= 2 and current ~= 4
	end
	if gx > 0 then
		can_move = goal ~=0 and goal ~= 2 and goal ~= 4
	end
	if gy < 0 then
		can_move = goal ~=0 and current ~= 3 and current ~= 4
	end
	if gy > 0 then
		can_move = goal ~=0 and goal ~= 3 and goal ~= 4
	end
	if can_move then 
		player.goal = {px+gx, py+gy}
	else 
		player.goal = player.pos
	end
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
	if player.moving == 0 then -- player is not currently moving
		-- check controls
		if k == "w" then --move forward
		move(0)
		elseif k == "d" then --strafe a tile right
		move(1)
		elseif k == "s" then --move backward
		move(2)
		elseif k == "a" then --strafe a tile left
		move(3)
		elseif k == "q" then --rotate ccw
			player.wishdir = (player.dir-1)
		elseif k == "e" then --rotate cw
			player.wishdir = (player.dir+1)
		else
			return
		end
		player.moving = movetime
	end
end
