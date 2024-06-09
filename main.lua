function love.load()
  game = {
    time = 0,
    scale = 6,
    player = {
      sprite = 1,
      x = 0, y = 0,
      px = 0, py = 0,
      flip = false,
      inv = {8, 8, 8+8, 8+8},
      inv_cur = 1,
      show_inv = false
    },
    map = {
      canvas = nil,
      width = 16,
      height = 9,

      ground = {},
      crops = {}
    },
    cam = {
      x = 0, y = 0
    },
    popup = {}
  }

  love.graphics.setDefaultFilter('nearest')
  require('src/id')
  require('src/lib')

  map()
end

function love.keypressed(_, scancode)
  local x, y = 0, 0
  if scancode == 'w' or scancode == 'up' then y = y - 1 end
  if scancode == 's' or scancode == 'down' then y = y + 1 end
  if scancode == 'a' or scancode == 'left' then x = x - 1 end
  if scancode == 'd' or scancode == 'right' then x = x + 1 end
  
  if not game.player.show_inv then
    game.player.flip = x == 0 and game.player.flip or x < 0
    game.player.x = game.player.x + x
    game.player.y = game.player.y + y

    if scancode == 'space' then action() end
  else
    game.player.inv_cur = (((game.player.inv_cur-1) + x) % #game.player.inv) + 1
  end
  if scancode == 'n' then day() end

  if scancode == 'p' then popup(ID.ITEM_WHEAT) end
  if scancode == 'i' then game.player.show_inv = not game.player.show_inv end

  if scancode == '1' then game.player.sprite = ID.CHARACTER_1 end
  if scancode == '2' then game.player.sprite = ID.CHARACTER_2 end
  if scancode == '3' then game.player.sprite = ID.CHARACTER_3 end
  if scancode == '4' then game.player.sprite = ID.CHARACTER_4 end
end

function love.update(dt)
  game.time = game.time + dt

  game.player.px = game.player.px + ((game.player.x * 8 * game.scale) - game.player.px) * 0.2
  game.player.py = game.player.py + ((game.player.y * 8 * game.scale) - game.player.py) * 0.2

  local center_x = math.floor(love.graphics.getWidth() / 2) - 8 * game.scale
  local center_y = math.floor(love.graphics.getHeight() / 2) - 8 * game.scale
  game.cam.x = game.cam.x + (center_x - game.player.px - game.cam.x) * 0.08
  game.cam.y = game.cam.y + (center_y - game.player.py - game.cam.y) * 0.08

  update_popup()
end

function love.draw()
  love.graphics.translate(game.cam.x, game.cam.y)
  love.graphics.draw(game.map.canvas, 0, 0, 0, game.scale)

  local n = game.player.sprite + math.floor(game.time % 2)
  sprite(n, game.player.px, game.player.py, game.scale, game.player.flip)

  draw_popup()

  love.graphics.origin()
  if game.player.show_inv then draw_inventory() end
end
