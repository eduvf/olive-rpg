function love.load()
  game = {
    time = 0,
    scale = 6,
    player = {
      sprite = 1,
      x = 0, y = 0,
      px = 0, py = 0,
      flip = false
    },
    map = {
      canvas = nil
    }
  }

  love.graphics.setDefaultFilter('nearest')
  require('src/lib')

  map()
end

function love.keypressed(_, scancode)
  if scancode == 'w' then game.player.y = game.player.y - 1 end
  if scancode == 's' then game.player.y = game.player.y + 1 end
  if scancode == 'a' then game.player.x = game.player.x - 1 end
  if scancode == 'd' then game.player.x = game.player.x + 1 end
end

function love.update(dt)
  game.time = game.time + dt

  game.player.px = game.player.px + ((game.player.x * 8 * game.scale) - game.player.px) * 0.2
  game.player.py = game.player.py + ((game.player.y * 8 * game.scale) - game.player.py) * 0.2
end

function love.draw()
  love.graphics.draw(game.map.canvas, 0, 0, 0, game.scale)

  local n = game.player.sprite + math.floor(game.time % 2)
  sprite(n, game.player.px, game.player.py, game.scale, game.player.flip)
end
