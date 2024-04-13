require 'src/player'

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
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(8, 0, 8, 8, game.gfx.forest.i)
  }
  game.gfx.home = {}
  game.gfx.home.i = love.graphics.newImage('gfx/home.png')
  game.gfx.home.q = {
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(8, 0, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(0, 8, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(8, 8, 8, 8, game.gfx.home.i)
  }
  
  game.object = {}
  game.object.home = {
    {3, 3, 3},
    {2, 1, 2},
    {0, 0, 4}
  }

  love.resize()

  player.load()

  input = {
    up = false,
    dn = false,
    lt = false,
    rt = false,
    prev = {
      up = false,
      dn = false,
      lt = false,
      rt = false,
    }
  }
end

function draw_object(obj, img, quad, ox, oy)
  for j = 1, #obj do
    for i = 1, #obj[j] do
      local id = obj[j][i]
      if id > 0 then
        local x = ox + i * 8
        local y = oy + j * 8
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', x, y, 8, 8)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(img, quad[id], x, y)
      end
    end
  end
end

function simple_grid()
  local w = math.floor(love.graphics.getWidth() / game.scale)
  local h = math.floor(love.graphics.getHeight() / game.scale)
  local canvas = love.graphics.newCanvas(w, h)

  love.graphics.setCanvas(canvas)
  local tile = game.gfx.forest.i
  local quad = game.gfx.forest.q
  for x = 0, w, 8 do
    for y = 0, h, 8 do
      local q = quad[1]
      if math.random() > 0.5 then
        q = quad[math.random(2)]
      end
      love.graphics.draw(tile, q, x, y)
    end
  end
  draw_object(game.object.home, game.gfx.home.i, game.gfx.home.q, 8, 8)
  love.graphics.setCanvas()

  return canvas
end

function love.resize()
  canvas = simple_grid()
end

function love.update(dt)
  game.time = game.time + dt

  input.up = love.keyboard.isScancodeDown('w', 'up')
  input.dn = love.keyboard.isScancodeDown('s', 'down')
  input.lt = love.keyboard.isScancodeDown('a', 'left')
  input.rt = love.keyboard.isScancodeDown('d', 'right')

  player.update(dt)

  input.prev.up = input.up
  input.prev.dn = input.dn
  input.prev.lt = input.lt
  input.prev.rt = input.rt
end

function love.draw()
  love.graphics.draw(canvas, 0, 0, 0, game.scale)
  player.draw()
end