function love.load()
  game = {
    time = 0,
    scale = 6,
    map = {
      canvas = nil
    }
  }

  love.graphics.setDefaultFilter('nearest')
  require('src/lib')

  map()
end

function love.update(dt)
  game.time = game.time + dt
end

function love.draw()
  love.graphics.draw(game.map.canvas, 0, 0, 0, game.scale)
  sprite(math.floor(game.time+1), 0, 0, game.scale)
end
