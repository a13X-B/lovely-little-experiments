--better restart
--read the rules
--research possibility of copying a picture
--pictures
--consider bg change instead of markers

local field = require("field")
local menu = require("menu")

local game = false

function love.mousepressed(x, y, b, t)
	if menu.start() then
		field.click(x, y)
	else
		menu.click(x,y)
		game = menu.start()
	end
end

function love.update(dt)
	if game then
		game = false
		field.new_field(menu.options())
	end
	love.timer.sleep(0.0333)
end

function love.draw()
	if menu.start() then
		field.draw()
	else
		menu.draw()
	end
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
	if k == "space" then love.event.quit("restart") end
end
