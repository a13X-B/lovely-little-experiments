--space to pause the game and bring up settings
--game has four states that you can color differently
--use "fixed" to toggle between fixed and relaxed update
--tickrate sets a tickrate for a fixed timestep
--frametime sets a minimum frametime in ms to simulate different framerates
--fluctuation adds a random frametime in ms to simulate unstable framerate

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
local frametime = 0
local flux = 0
local tickrate = 24
local fdt = 1/tickrate
local time_budget = 0
local fixed = true
local paused = false

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
	if frametime/1000 - dt > 0 then love.timer.sleep(frametime/1000 - dt) end
	if flux > 0 then love.timer.sleep(love.math.random(0, flux)/1000) end
end

function draw(state)
	for i = 0, 1 do
		g.rectangle("line", state.paddle[i].x-10, state.paddle[i].y-state.paddle[i].h*0.5, 20, state.paddle[i].h)
	end
	g.circle("line", state.ball.x, state.ball.y, 10)
end

--(arguably) pretty colors
local colors = {
	{0,0,0,0},-- 1 invisible
	{1,0,0,1},-- 2 red
	{0,1,0,1},-- 3 green
	{0,0,1,1},-- 4 blue
	{0,1,1,1},-- 5 cyan
	{1,0,1,1},-- 6 magenta
	{1,1,0,1},-- 7 yellow
	{1,1,1,1},-- 8 white
}
local old_color = 4
local new_color = 2
local inter_color = 8
local extra_color = 1

local buttons = {}

function love.draw()
	g.setColor(colors[old_color])
	draw(old)
	g.setColor(colors[new_color])
	draw(new)
	g.setColor(colors[inter_color])
	draw(interpol)
	g.setColor(colors[extra_color])
	draw(extrapol)
	g.setColor(colors[#colors])
	g.print(score[1]..":"..score[2], 400-13, 20)
	g.print(love.timer.getFPS(), 10, 10)

	--pause menu incoming, no one said it's gonna be pretty
	if paused then
		g.print("colors", 100, 70)
		g.print("old", 50, 100)
		g.print("new", 50, 130)
		g.print("interp", 50, 160)
		g.print("extrap", 50, 190)

		g.print("sim", 450, 70)
		g.print("fixed", 350, 100)
		g.print("tickrate", 350, 130)
		g.print("frametime", 350, 160)
		g.print("fluctuation", 350, 190)

		g.print(tostring(fixed), 450, 100)
		g.print(tickrate, 450, 130)
		g.print(frametime, 450, 160)
		g.print(flux, 450, 190)
		for i = 1, 3 do
			g.print("-10  -1  +1  +10", 475, 100+i*30)
		end

		for i, v in ipairs(buttons) do
			g.rectangle("line", v.x, v.y, v.w, v.h)
		end

		g.setColor(colors[old_color])
		g.rectangle("fill", 75+old_color*25 + 3, 103, 14, 14)
		g.setColor(colors[new_color])
		g.rectangle("fill", 75+new_color*25 + 3, 133, 14, 14)
		g.setColor(colors[inter_color])
		g.rectangle("fill", 75+inter_color*25 + 3, 163, 14, 14)
		g.setColor(colors[extra_color])
		g.rectangle("fill", 75+extra_color*25 + 3, 193, 14, 14)
	end
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
	if k == "space" then paused = not paused end
end

--all the pause menu buttons
for i = 1, 4 do
	for j = 1, 8 do
		buttons[#buttons + 1] = {x = 75+j*25, y = 70+i*30, w = 20, h = 20, f="c"..tostring(i), p = j}
	end
end
buttons[#buttons + 1] = {x = 440, y = 100, w = 50, h = 20, f="fix"}
for i = 1, 3 do
	buttons[#buttons + 1] = {x = 475, y = 100 + 30*i, w = 20, h = 20, f="t"..tostring(i), p = -10}
	buttons[#buttons + 1] = {x = 500, y = 100 + 30*i, w = 20, h = 20, f="t"..tostring(i), p =  -1}
	buttons[#buttons + 1] = {x = 525, y = 100 + 30*i, w = 20, h = 20, f="t"..tostring(i), p =   1}
	buttons[#buttons + 1] = {x = 550, y = 100 + 30*i, w = 20, h = 20, f="t"..tostring(i), p =  10}
end

--and when you thought that menu rendering was ugly
local fun = {}
function fun.c1(c)
	old_color = c
end
function fun.c2(c)
	new_color = c
end
function fun.c3(c)
	inter_color = c
end
function fun.c4(c)
	extra_color = c
end
function fun.fix()
	fixed = not fixed
	fdt = 1/tickrate
end
function fun.t1(n)
	tickrate = math.min(math.max(10, tickrate+n),200)
	fdt = 1/tickrate
end
function fun.t2(n)
	frametime = math.min(math.max(0, frametime+n),50)
end
function fun.t3(n)
	flux = math.min(math.max(0, flux+n),50)
end

function love.mousepressed(x,y,b)
	if not paused then return end
	for i, v in ipairs(buttons) do
		if x >= v.x and x <= v.x+v.w and y >= v.y and y <= v.y+v.h then
			fun[v.f](v.p)
		end
	end
end
