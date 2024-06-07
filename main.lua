function love.load()
  game = {
    time = 0,
    scale = 6
  }

  love.graphics.setDefaultFilter('nearest')
  require('src/lib')
end

function love.update(dt)
  game.time = game.time + dt
end

function love.draw()
  sprite(math.floor(game.time+1), 0, 0, true)
end