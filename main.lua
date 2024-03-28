function love.load()
  love.graphics.setDefaultFilter('nearest')

  game = {
    scale = 6,
    time = 0
  }
  
  game.gfx = {}
  game.gfx.forest = {}
  game.gfx.forest.i = love.graphics.newImage('gfx/forest.png')
  game.gfx.forest.q = {
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.forest.i)
  }

  love.resize()

  game.player = {
    x = 0,
    y = 0,
    px = 0,
    py = 0,
    flip = false
  }
  p = game.player
  p.spr = love.graphics.newImage('gfx/player.png')
  p.quad = {
    love.graphics.newQuad(0, 0, 8, 8, p.spr),
    love.graphics.newQuad(8, 0, 8, 8, p.spr)
  }

  game.input = {
    up = false,
    dn = false,
    lt = false,
    rt = false,
  }
end

function simple_grid()
  local w = math.floor(love.graphics.getWidth() / game.scale)
  local h = math.floor(love.graphics.getHeight() / game.scale)
  local canvas = love.graphics.newCanvas(w, h)

  love.graphics.setCanvas(canvas)
  local tile = game.gfx.forest.i
  local quad = game.gfx.forest.q[1]
  for x = 0, w, 8 do
    for y = 0, h, 8 do
      love.graphics.draw(tile, quad, x, y)
    end
  end
  love.graphics.setCanvas()

  return canvas
end

function love.resize()
  canvas = simple_grid()
end

function love.update(dt)
  game.time = game.time + dt

  local up = love.keyboard.isScancodeDown('w', 'up')
  local dn = love.keyboard.isScancodeDown('s', 'down')
  local lt = love.keyboard.isScancodeDown('a', 'left')
  local rt = love.keyboard.isScancodeDown('d', 'right')

  local x, y = 0, 0
  if up then y = y - 1 end
  if dn then y = y + 1 end
  if lt then x = x - 1 end
  if rt then x = x + 1 end

  local dist = 0.5
  if math.abs(p.px - p.x) < dist and math.abs(p.py - p.y) < dist then
    if x ~= 0 or y ~= 0 then
      p.x = p.x + x * 8
      p.y = p.y + y * 8
    end
  else
    if up and not game.input.up then p.y = p.y - 8 end
    if dn and not game.input.dn then p.y = p.y + 8 end
    if lt and not game.input.lt then p.x = p.x - 8 end
    if rt and not game.input.rt then p.x = p.x + 8 end
  end
  p.px = p.px - (p.px - p.x) * dt * 10
  p.py = p.py - (p.py - p.y) * dt * 10

  if lt then p.flip = true end
  if rt then p.flip = false end

  game.input.up = up
  game.input.dn = dn
  game.input.lt = lt
  game.input.rt = rt
end

function love.draw()
  love.graphics.draw(canvas, 0, 0, 0, game.scale)
  local x = p.px * game.scale
  local y = p.py * game.scale
  local anim = math.floor(game.time * 2) % 2 + 1
  local sx, sy = game.scale, game.scale
  local ox, oy = 0, 0
  if p.flip then
    x = x + game.scale
    sx = sx * -1
    ox = game.scale
  end
  love.graphics.draw(p.spr, p.quad[anim], x, y, 0, sx, sy, ox, oy)
end