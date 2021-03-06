local opt = {
	row = 5,
	col = 5,
	first = "red",
	hitman = true,
	pic = false,
	score = 9
}

local norm = function()
	opt.row = math.max(math.min(opt.row,5), 3)
	opt.col = math.max(math.min(opt.col,5), 3)
	opt.score = math.max(math.min(opt.score, math.floor(opt.row*opt.col/2)), 4)
end

local buttons = {
	{x=500,y=100,w=300,h=100,t="r ^",f="ru"},
	{x=500,y=200,w=300,h=100,t="r v",f="rd"},
	{x=800,y=100,w=300,h=100,t="c ^",f="cu"},
	{x=800,y=200,w=300,h=100,t="c v",f="cd"},
	{x=10,y=10,w=10,h=10,t="s ^",f="su"},
	{x=10,y=10,w=10,h=10,t="s v",f="sd"},
	{x=650,y=350,w=100,h=100,t="red\nstarts",f="r"},
	{x=850,y=350,w=100,h=100,t="blue\nstarts",f="b"},
	{x=700,y=500,w=200,h=100,t="hitman",f="h"},
	{x=1000,y=500,w=200,h=100,t="pictures",f="p"},
	{x=1300,y=600,w=200,h=100,t="begin",f="s"},
}

local begin = false
local press = function(f)
	if f == "s" then begin = true end
	if f == "h" then opt.hitman = not opt.hitman end
	if f == "p" then opt.pic = not opt.pic end
	if f == "r" then opt.first = "red" end
	if f == "b" then opt.first = "blue" end
	if f == "ru" then opt.row = opt.row + 1 end
	if f == "rd" then opt.row = opt.row - 1 end
	if f == "cu" then opt.col = opt.col + 1 end
	if f == "cd" then opt.col = opt.col - 1 end
	if f == "su" then opt.score = opt.score + 1 end
	if f == "sd" then opt.score = opt.score - 1 end
	norm()
end

local click = function(x, y)
	for i,v in ipairs(buttons) do
		if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
			press(v.f)
		end
	end
end

local g = love.graphics

local draw = function()
	for i,v in ipairs(buttons) do
		g.rectangle("line", v.x, v.y, v.w, v.h)
		g.print(v.t, v.x, v.y)
	end
	g.print(opt.row, 20, 20)
	g.print(opt.col, 20, 50)
	g.print(opt.first, 20, 80)
	g.print(opt.score, 20, 110)
end


return {
	start = function() return begin end,
	options = function() return opt end,
	draw = draw,
	click = click,
}