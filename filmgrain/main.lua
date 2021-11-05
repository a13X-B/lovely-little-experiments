local g = love.graphics

--load a bunch of pictures
local arch = g.newImage("arch.jpg", {mipmaps = true})
local glass = g.newImage("glass.jpg", {mipmaps = true})
local stairs = g.newImage("stairs.jpg", {mipmaps = true})

local screen = g.newCanvas() --screen sized canvas for post effect(s)
local grain = g.newShader("grain.glsl")

--noise generation
local noise_size = 128
local noise_data = love.image.newImageData(noise_size, noise_size)
local function noise_f(x,y,r,g,b,a)
	return love.math.noise(x,y), love.math.noise(x+noise_size,y), love.math.noise(x,y+noise_size), 1
end

noise_data:mapPixel(noise_f)

local noise = g.newImage(noise_data)
noise:setWrap("repeat")

local random_offset = {}

function love.draw()
	g.setCanvas(screen)
	g.draw(arch, 0, 0, 0, 0.35, 0.35)
	g.draw(glass, 600, 0, 0, 0.3, 0.3)
	g.draw(stairs, 1200, 0, 0, 0.19, 0.19)
	g.setCanvas()
	g.setShader(grain)
	grain:send("noise_texture", noise)
	--we will send a random offset vector to alternate the noise each frame
	random_offset[1] = love.math.random()
	random_offset[2] = love.math.random()
	grain:send("random_offset", random_offset)
	g.draw(screen)
	g.setShader()
	--love.timer.sleep(1/24) --cinematic mode
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
