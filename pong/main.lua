local paddle = {
  {x = 50, y = 300, v = 320, h = 90},
  {x = 750, y = 300, v = 400, h = 90}
}
local ball = {x = 400, y = 300, vx = 1, vy = 0, v = 420}
local control = {
  {up = false, down = false},
  {up = false, down = false}
}
local score = {0,0}
local m = {1,-1}

local fdt = 1/125
local t = 0

local function goal(s)
  score[s] = score[s] + 1
  ball.x, ball.y, ball.vx, ball.vy, ball.v = 400, 300, m[s], 0, 320
end

local function fupdate()
  control[1].up, control[1].down = love.keyboard.isDown("up"), love.keyboard.isDown("down")
  control[2].up, control[2].down = ball.y < paddle[2].y-30, ball.y > paddle[2].y+30
  
  for i,v in ipairs(paddle) do
    paddle[i].y = paddle[i].y + paddle[i].v * fdt * ((control[i].up and -1) or (control[i].down and 1) or 0)
  end

  ball.x, ball.y = ball.x + ball.vx * fdt * ball.v, ball.y + ball.vy * fdt * ball.v
  
  for i,v in ipairs(paddle) do
    if  (math.abs(ball.x - paddle[i].x) < 20) and
        (math.abs(ball.y - paddle[i].y) < 10 + paddle[i].h*0.5)
    then
      local nx, ny = (ball.x - paddle[i].x), (ball.y - paddle[i].y)
      local l = math.sqrt(nx*nx+ny*ny)
      nx, ny = nx/l, ny/l
      nx = m[i]*math.abs(ball.vx) + nx
      ny = ball.vy + ny
      l = math.sqrt(nx*nx+ny*ny)
      ball.vx = nx/l
      ball.vy = ny/l
      ball.v = math.min(ball.v*1.1, 1666)
    end
  end
  
  if ball.y < 10 then ball.vy = math.abs(ball.vy) end
  if ball.y > 590 then ball.vy = -math.abs(ball.vy) end

  _ = (ball.x < 0) and goal(2)
  _ = (ball.x > 800) and goal(1)
end

function love.update(dt)
  t = t + dt
  if t > fdt then
    t = t - fdt
    fupdate()
  end
end

function love.draw()
  for i, v in ipairs(paddle) do
    love.graphics.rectangle("fill", paddle[i].x-10, paddle[i].y-paddle[i].h*0.5, 20, paddle[i].h)
  end
  love.graphics.circle("fill", ball.x, ball.y, 10)
  love.graphics.print(score[1]..":"..score[2], 400-13, 20)
end

function love.keypressed(k,s,r)
  if k == "escape" then love.event.quit(0) end
end