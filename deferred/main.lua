local Gamera = require("gamera")
local sin = math.sin
local random = love.math.random

local img_player, img_house
local quad
local quad_i = 0
local max_col = 4
local timer = 0
local gbuffer = {}
local geometry_pass
local lighting_pass
local camera

local max_lights = 1000
local current_plights = 666

local lvfp = {{"lpos", "float", 4}} -- pos.xyz, scale
local lvft = {{"ldir", "float", 4}} -- dir.xyz, angle
local lvfd = {{"diffuse", "float", 3}} -- color
local r = {math.cos(math.pi/32), math.sin(math.pi/32)}

function create_point_light()
	local v = {{0,0, 0,0, 0,0,0,1}, {0,1, 0,0, 1,1,1,1}}
	for i = 1, 64 do
		local t = v[#v]
		v[#v+1] = {t[1]*r[1] - t[2]*r[2], t[1]*r[2] + t[2]*r[1], 0,0, 1,1,1,1}
	end
	local pointlight = love.graphics.newMesh( v, nil, "static")
	local pl_position = love.graphics.newMesh(lvfp, max_lights)
	local pl_diffuse =  love.graphics.newMesh(lvfd, max_lights)
	local pl_direction = love.graphics.newMesh(lvft, max_lights)

	pl_diffuse:setVertex(1, {0.8, 0.5, 0.1})

	pl_position:setVertex(2, {731,295,5,166})
	pl_diffuse:setVertex(2, {1, 1, 1})

	pl_position:setVertex(3, {731,295,15,466})
	pl_diffuse:setVertex(3, {1, 1, 1.2})
	pl_direction:setVertex(3,{-1, 0.4, -0.3, 0.8})

	pl_position:setVertex(4, {446,243,10,466})
	pl_diffuse:setVertex(4, {0.8, 0.7, 0.6})
	pl_direction:setVertex(4,{0, 1, -0.3, 0.8})

	for i = 5, current_plights do
		pl_position:setVertex(i, {random(470, 994),random(0, 270),random(1,10),random(5, 25)})
		pl_diffuse:setVertex(i, {random()*.3, random()*.3, random()*.3})
	end
	pointlight:attachAttribute("lpos", pl_position, "perinstance")
	pointlight:attachAttribute("diffuse", pl_diffuse, "perinstance")
	pointlight:attachAttribute("ldir", pl_direction, "perinstance")
	return {
		light = pointlight,
		pos = pl_position,
		diffuse = pl_diffuse,
	}
end

local pointlight = create_point_light()

local function draw_lights()
	love.graphics.drawInstanced(pointlight.light, current_plights)
end

function love.load()
	love.window.setMode(1024, 720)
	love.graphics.setDefaultFilter("nearest", "nearest")

	local house = {
		"house.png",
		"n_house.png",
	}
	local player = {
		"player.png",
		"n_player.png"
	}

	img_house = love.graphics.newArrayImage(house)
	img_player = love.graphics.newArrayImage(player)
	quad = love.graphics.newQuad(0, 0, 16, 58, img_player:getWidth(), img_player:getHeight())

	gbuffer[1] = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight()) --color
	gbuffer[2] = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight()) --normals

	geometry_pass = love.graphics.newShader("geometry_pass.glsl")
	lighting_pass = love.graphics.newShader("lighting_pass.glsl")

	local w, h = love.graphics.getDimensions()
	camera = Gamera.new(0, 0, w * 2, h)
	camera:setWindow(0, 0, w, h)
	camera:setScale(2)
	camera:setPosition(0, -h)
end

local mmx,mmy
function love.draw()
	camera:attach()
	love.graphics.setCanvas(gbuffer[1], gbuffer[2])
	love.graphics.clear()
	love.graphics.setShader(geometry_pass)
	love.graphics.setColor(1, 1, 1, 1)
	local _, _, cww, cwh = camera:getWorld()
	local _, _, cvw, cvh = camera:getVisible()
	local hw, hh = img_house:getDimensions()
	local _, _, pw, ph = quad:getViewport()
	love.graphics.drawLayer(img_house, 1)
	love.graphics.drawLayer(img_player, 1, quad, 487, 292, 0, 1, 1, pw/2, ph/2)

	love.graphics.setCanvas()
	lighting_pass:send("cb", gbuffer[1])
	lighting_pass:send("nb", gbuffer[2])
	love.graphics.clear()
	love.graphics.setBlendMode("add")
	love.graphics.setShader(lighting_pass)
	draw_lights()
	love.graphics.setShader()
	camera:detach()

	love.graphics.setColor(.2, .2, .24, 1) --ambient light color
	love.graphics.draw(gbuffer[1])

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setBlendMode("alpha")
end

local cam_speed = 227
function love.update(dt)
	local x, y = camera:getPosition()
	if love.keyboard.isDown("a") then
		x = x - cam_speed * dt
	elseif love.keyboard.isDown("d") then
		x = math.min(730, x + cam_speed * dt)
	end
	if love.keyboard.isDown("w") then
		y = y - cam_speed * dt
	elseif love.keyboard.isDown("s") then
		y = y + cam_speed * dt
	end
	camera:setPosition(x, y)

	local mx, my = love.mouse.getPosition()
	mmx,mmy = camera:toWorld(mx,my)
	mx, my = mmx, mmy
	pointlight.pos:setVertex(1, {mmx,mmy,14,66})
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
