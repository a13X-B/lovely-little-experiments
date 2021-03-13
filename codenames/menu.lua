local opt = {
	row = 5,
	col = 5,
	first = "red",
	hitman = true,
	pic = false,
	score = 9
}

local colors = {
	red = {1,0,0,1},
	blue = {0,0,1,1},
	white = {1,1,1,1},
	black = {0,0,0,1},
}

local g = love.graphics

local font = g.newFont(92, "normal", 1.25)
local score = g.newText(font, opt.score)

local norm = function()
	opt.row = math.max(math.min(opt.row,5), 3)
	opt.col = math.max(math.min(opt.col,5), 3)
	opt.score = math.max(math.min(opt.score, math.floor(opt.row*opt.col/2)), 4)
	score = g.newText(font, opt.score)
end

local buttons = {
	{x=500-120,y=400-120,w=120,h=120,t="r ^",f="ru"},
	{x=500-120,y=400,w=120,h=120,t="r v",f="rd"},
	{x=675,y=550,w=120,h=120,t="c >",f="cu"},
	{x=650-120,y=550,w=120,h=120,t="c <",f="cd"},
	{x=800+150,y=250-120,w=120,h=120,t="s >",f="su"},
	{x=950-145,y=250-120,w=120,h=120,t="s <",f="sd"},
	{x=800+300,y=400-120,w=120,h=120,t="starting\nteam",f="st"},
	{x=1100,y=400,w=120,h=120,t="hitman",f="h"},
	{x=800-300,y=400-150,w=600,h=300,t="pictures",f="p"},
	{x=1310,y=585,w=130,h=130,t="begin",f="s"},
}

local begin = false
local press = function(f)
	if f == "s" then begin = true end
	if f == "h" then opt.hitman = not opt.hitman end
	if f == "p" then opt.pic = not opt.pic end
	if f == "st" then opt.first = ((opt.first=="red") and "blue" or "red") end
	if f == "ru" then opt.row = opt.row + 1 end
	if f == "rd" then opt.row = opt.row - 1 end
	if f == "cu" then opt.col = opt.col + 1 end
	if f == "cd" then opt.col = opt.col - 1 end
	if f == "su" then opt.score = opt.score + 1 end
	if f == "sd" then opt.score = opt.score - 1 end
	norm()
end

local reset = function()
	begin = false
end

local click = function(x, y)
	for i,v in ipairs(buttons) do
		if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
			press(v.f)
		end
	end
end

local random = love.math.newRandomGenerator(31337)
local r_state = random:getState()

local function arrow(x,y,r)
	g.translate(x, y)
	g.rotate(r or 0)
	g.line(0,-15, 0,15)
	g.arc("line","open", 0,-140, 140, math.pi/2, math.pi/2-.255)
	g.arc("line","open", 0, 140, 140, -math.pi/2, .255-math.pi/2)
	g.arc("line","open", 41, 0, 7, -math.pi*3/4, -math.pi*5/4)
	g.origin()
end

local draw = function()
	random:setState(r_state)
	g.setLineWidth(1)
	g.setColor(colors.white)

	--start button
	g.circle("line", 1375, 650, 65)
	g.polygon("line", {1350,600, 1416,650, 1350,700})

	--pretty stuff
	g.setLineWidth(0.7)
	arrow(500-13.5,252, math.pi/2)
	arrow(500-13.5,548,-math.pi/2)
	arrow(502,570-7.5)
	arrow(1100-2, 570-7.5, math.pi)
	g.line(490-3.5, 252, 490-3.5, 548)
	g.line(502, 570-7.5, 1100-2, 570-7.5)

	--score controls
	g.draw(score, (1875 - score:getWidth())/2, 190-score:getHeight()/2)

	--field preview
	local w, h = 600/opt.col, 300/opt.row
	for y=0, opt.row-1 do
		for x=0, opt.col-1 do
			g.rectangle("line", 802-300 + x*w, 252 + y*h, w-4,h-4, 7,7,5)
			if opt.pic then
			else
			end
		end
	end

	--starting team
	g.setColor(colors[opt.first])
	g.circle("fill", 1160, 340, 50)

	--debug crap
	---[[
	for i,v in ipairs(buttons) do
		g.rectangle("line", v.x, v.y, v.w, v.h)
		g.print(v.t, v.x, v.y)
	end
	--]]
	g.print("hitman "..tostring(opt.hitman), 20, 20)
	g.print("pic "..tostring(opt.pic), 20, 50)
end


return {
	start = function() return begin end,
	options = function() return opt end,
	draw = draw,
	click = click,
	reset = reset,
}