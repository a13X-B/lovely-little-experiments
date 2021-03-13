local words = require("words")
local pics = {}--require("pics")

local g = love.graphics
local font = g.newFont(64, "normal", 1.25)
local text_scale

local w, h = g.getDimensions()

local row, col
local tw, th
local ox, oy

local cards = {}

local colors = {
	red = {1,0,0,1},
	blue = {0,0,1,1},
	white = {1,1,1,1},
	black = {0,0,0,1},
}

local function bag_cards(amount, pic)
	local items = pic and pics or words
	local total = #items
	local bag = {}
	text_scale = 0
	for i = 1, amount do
		local r = love.math.random(1, total)
		local t = {g.newText(font, items[r]), items[r]}
		text_scale = math.max(t[1]:getWidth(), text_scale)
		bag[#bag + 1] = t
		items[r], items[total] = items[total], items[r]
		total = total - 1
	end
	return bag
end

local function bag_keys(amount, opt)
	local bag = {}
	for i = 1, opt.score do
		bag[#bag+1] = "red"
		bag[#bag+1] = "blue"
	end
	bag[(opt.first == "red") and 2 or 1] = opt.hitman and "black" or "white"
	for i = #bag+1, opt.col*opt.row do
		bag[i] = "white"
	end
	return bag
end

local random_state
local new_field = function(opt)
	row, col = opt.row, opt.col
	local tiles = row*col
	tw, th = w / col, h / row
	local cw, ch = math.floor(tw) - 14, math.floor(th) - 14
	ox, oy = cw / 2, ch / 2

	local words = bag_cards(tiles, opt.pic)
	local keys = bag_keys(tiles, opt)

	text_scale = (cw - 20) / text_scale 

	cards = {}
	for r = 1, row do
		cards[r] = {}
		for c = 1, col do
			local k = love.math.random(1, #keys)
			local f = {
				sprite = g.newCanvas(cw, ch, {msaa=8}),
				key = keys[k],
				word = words[#words][2],
				hidden = true,
			}
			keys[k] = keys[#keys]
			keys[#keys] = nil
			g.setCanvas(f.sprite)
			g.draw(words[#words][1], ox, oy, 0, text_scale, text_scale,
				words[#words][1]:getWidth()/2, words[#words][1]:getHeight()/2)
			g.setLineWidth(3)
			g.rectangle("line", 0, 0, cw, ch, 10, 10, 5)
			g.setCanvas()
			words[#words] = nil
			cards[r][c] = f
		end
	end
	local blue_keys, red_keys, keys = "", "", ""
	for r=1,row do
		for c=1,col do
			local card = cards[r][c]
			if card.key == "red" then red_keys = red_keys..card.word.." " end
			if card.key == "blue" then blue_keys = blue_keys..card.word.." " end
			if card.key == "black" then keys = "HITMAN: "..card.word.."\n" end
		end
	end
	keys = keys.."RED: "..red_keys.."\n"
	keys = keys.."BLUE: "..blue_keys
	love.system.setClipboardText( keys )
	random_state = love.math.getRandomState()
end

local draw = function()
	love.math.setRandomState(random_state)
	for r = 1, row do
		for c = 1, col do
			local card = cards[r][c]
			g.draw(card.sprite, (c-1)*tw + tw/2, (r-1)*th + th/2,
				(love.math.random() - 0.5) * 0.07, 1, 1, ox, oy)
		end
	end
end

local function click(x, y)
	local c, r = math.floor(x/tw) + 1, math.floor(y/th) + 1
	local card = cards[r][c]
	if card.hidden then
		card.hidden = false
		g.setCanvas(card.sprite)
		g.setColor(colors[card.key])
		love.math.setRandomSeed(love.timer.getTime())
		local x, y = love.math.random(0,ox) + ox/2, love.math.random(0,oy) + oy/2
		g.circle("fill", 50, 50, 25)
		g.setColor(1,1,1,1)
		g.circle("line", 50, 50, 25)
		g.setCanvas()
	end
end

return {
	new_field = new_field,
	draw = draw,
	click = click,
}