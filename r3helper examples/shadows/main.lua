local g = love.graphics
local R3 = require("R3helper")
local scene = require("scene")

local res = 1024
local shadow_inv = R3.new_inverse(res,res)

--this preferably should be computed to cover as much frustum as possible
local shadow_proj = R3.new_ortho(26,26, -11.7, 11.7)
shadow_proj:apply(
	R3.rotate(R3.aa_to_quat(1,0,0,.3)) *
	R3.rotate(R3.aa_to_quat(0,1,0,.3))
)
local shadow_view = shadow_proj

local shadow_map = {}
do
	shadow_map.depthstencil = g.newCanvas(res, res, {type="2d", format="depth32f", readable=true})
	shadow_map.depthstencil:setDepthSampleMode("gequal")
end
local shadow_shader = g.newShader("sm.glsl")

local w,h = g.getDimensions()
local proj = R3.new_perspective(w,h, .1, math.pi/3)

function love.draw()
	local t = love.timer.getTime()
	g.setDepthMode("less", true)
	g.setMeshCullMode("front")

--set depth
	g.setCanvas(shadow_map)
	g.clear(0,0,0,0,false,true)
	g.replaceTransform(shadow_inv*shadow_proj)
	scene.draw()

	g.setCanvas()
	g.setMeshCullMode("back")
	--set shader
	g.setShader(shadow_shader)
	shadow_shader:send("sm", shadow_map.depthstencil)
	shadow_shader:send("shadow_view", shadow_view)
	shadow_shader:send("proj", proj *
		R3.rotate(R3.aa_to_quat(1,0,0,.3)) * --rotate the camera
		R3.translate(0,-4,14) * --move the camera
		R3.rotate(R3.aa_to_quat(0,1,0,love.timer.getTime()%(math.pi*2))) --rotate the camera
	)
	g.origin()
	scene.draw()

	g.setShader()
	g.origin()
	g.setDepthMode("always", false)
	g.print(love.timer.getDelta())
	g.print(g.getStats().drawcalls, 0, 20)
	g.print(love.timer.getFPS(), 0, 40)
end

function love.keypressed(k,s,r)
	if k == "escape" then love.event.quit(0) end
end
