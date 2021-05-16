--usual pong stuff that we'll need
local ffi = require("ffi")
local g = love.graphics

--we'll need a memory mappable gamestate for easier inter/extrapolation
--brace for C structures
ffi.cdef[[
	struct paddle {
		double x, y, v, h;
	};

	struct ball {
		double x, y, vx, vy, v;
	};

	typedef struct game_state {
		struct paddle paddle[2];
		struct ball ball;
	} game_state;
	
	void* malloc(size_t);
	void* memcpy(void*, const void*, size_t);
]]
local double_a = ffi.typeof("double*")
local double_s = ffi.sizeof("double")
local game_state_size = ffi.sizeof("game_state")

local new = ffi.cast("game_state*", ffi.C.malloc(game_state_size))
local old = ffi.cast("game_state*", ffi.C.malloc(game_state_size))

local interpol = ffi.cast("game_state*", ffi.C.malloc(game_state_size))
local extrapol = ffi.cast("game_state*", ffi.C.malloc(game_state_size))
--inter/extrapolation array representations of the game state don't juggle
--so let's define 'em in advance
local extra_num, inter_num = ffi.cast(double_a, extrapol), ffi.cast(double_a, interpol)

--init game state
new.paddle[0].x = 50
new.paddle[0].y = 300
new.paddle[0].v = 320
new.paddle[0].h = 90

new.paddle[1].x = 750
new.paddle[1].y = 300
new.paddle[1].v = 320
new.paddle[1].h = 90

new.ball.x = 400
new.ball.y = 300
new.ball.vx = 1
new.ball.vy = 0
new.ball.v = 420

ffi.copy(old, new, game_state_size)

--not interpolated game state
local control = {{up = false, down = false}, {up = false, down = false}}
local score = {0,0}
local m = {1,-1}

--simulation settings
local tickrate = 24
local fdt = 1/tickrate
local time_budget = 0
local fixed = true

local function goal(s)
	score[s] = score[s] + 1
	new.ball.x, new.ball.y, new.ball.vx, new.ball.vy, new.ball.v = 400, 300, m[s], 0, 320
	old.ball.x, old.ball.y = 400, 300--fixes interpolation error, try without it
end

--fixed update always updates the new one
local function fupdate()
	old, new = new, old --we keep the old one for interpolation
	--then we copy the old one over the new one so we can mess it up
	ffi.copy(new, old, game_state_size)
	control[1].up, control[1].down = love.keyboard.isDown("up"), love.keyboard.isDown("down")
	control[2].up = new.ball.y < new.paddle[1].y-30
	control[2].down = new.ball.y > new.paddle[1].y+30

	--move the paddles
	for i = 0, 1 do
		new.paddle[i].y = new.paddle[i].y + new.paddle[i].v * fdt * ((control[i+1].up and -1) or (control[i+1].down and 1) or 0)
	end

	--move the ball
	new.ball.x = new.ball.x + new.ball.vx * fdt * new.ball.v
	new.ball.y = new.ball.y + new.ball.vy * fdt * new.ball.v

	--bounce off of paddles
	for i = 0, 1 do
		if  (math.abs(new.ball.x - new.paddle[i].x) < 20) and
				(math.abs(new.ball.y - new.paddle[i].y) < 10 + new.paddle[i].h*0.5)
		then
			local nx, ny = (new.ball.x - new.paddle[i].x), (new.ball.y - new.paddle[i].y)
			local l = math.sqrt(nx*nx+ny*ny)
			nx, ny = nx/l, ny/l
			nx = m[i+1]*math.abs(new.ball.vx) + nx
			ny = new.ball.vy + ny
			l = math.sqrt(nx*nx+ny*ny)
			l = l > 0 and l or 1
			new.ball.vx = nx/l
			new.ball.vy = ny/l
			new.ball.v = math.min(new.ball.v*1.1, 1666)
		end
	end

	--bounce off of walls
	if new.ball.y < 10 then new.ball.vy = math.abs(new.ball.vy) end
	if new.ball.y > 590 then new.ball.vy = -math.abs(new.ball.vy) end

	--score!
	_ = (new.ball.x < 0) and goal(2)
	_ = (new.ball.x > 800) and goal(1)
end

function love.update(dt)
	if paused then return end
	time_budget = time_budget + dt
	if not fixed then
		time_budget = dt*1.5 --
		fdt = dt
	end
	while time_budget > fdt do
		time_budget = time_budget - fdt
		fupdate()
	end
	if not fixed then time_budget = 0 end

	--the whole point of this experiment
	local xdt = time_budget/fdt
	local old_num, new_num = ffi.cast(double_a, old), ffi.cast(double_a, new)
	for i = 0, game_state_size/double_s - 1 do
		local vector = (new_num[i] - old_num[i]) * xdt --you can think of it as a sort of
		extra_num[i] = new_num[i] + vector      --verlet integraion
		inter_num[i] = old_num[i] + vector
	end
end

function draw(state)
	for i = 0, 1 do
		g.rectangle("line", state.paddle[i].x-10, state.paddle[i].y-state.paddle[i].h*0.5, 20, state.paddle[i].h)
	end
	g.circle("line", state.ball.x, state.ball.y, 10)
end

function love.draw()
	draw(new)
	draw(interpol)
	draw(extrapol)
	g.print(score[1]..":"..score[2], 400-13, 20)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end