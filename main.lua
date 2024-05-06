require 'src/player'

function love.load()
  love.graphics.setDefaultFilter('nearest')

  game = {
    scale = 6,
    time = 0
  }
  game.cam = {
    x = 0,
    y = 0,
    diff = 0.05
  }

  game.message = {}
  game.message.queue = {}
  game.message.add_message = function(text, x, y)
    table.insert(game.message.queue, {
      text = text,
      x = x * 8 * game.scale,
      y = y * 8 * game.scale,
      duration = 100,
      total_duration = 100
    })
  end
  game.message.update_messages = function()
    local m = 1
    while m <= #game.message.queue do
      local message = game.message.queue[m]
      if message.duration <= 0 then
        table.remove(game.message.queue, m)
      else
        game.message.queue[m].duration = message.duration - 1
        m = m + 1
      end
    end
  end
  game.message.display_messages = function()
    for m = 1, #game.message.queue do
      local message = game.message.queue[m]
      local total = message.total_duration * 0.5
      local alpha = 1
      if message.duration < total then
        alpha = message.duration / total
      end
      love.graphics.setColor(1, 1, 1, alpha)
      love.graphics.print(message.text, message.x, message.y, 0, 2)
    end
    love.graphics.setColor(1, 1, 1)
  end

  test_map = require 'map/test'

  game.map = {}
  game.map.width = 0
  game.map.height = 0
  game.map.layout = {}
  game.map.within_boundaries = function(x, y)
    local within_x = 0 <= x and x < game.map.width
    local within_y = 0 <= y and y < game.map.height
    return within_x and within_y
  end
  game.map.is_wall = function(x, y)
    if game.map.within_boundaries(x, y) then
      local cell = (x + y * game.map.width) + 1
      if bit.band(game.map.layout[cell], 0x80) == 0 then
        return false
      end
    end
    return true
  end
  game.map.check_panel = function(x, y)
    if game.map.within_boundaries(x, y) then
      local cell = (x + y * game.map.width) + 1
      local char = game.map.layout[cell]
      char = bit.band(char, 0xF00)
      char = bit.rshift(char, 8)
      if char ~= 0 then
        local message = game.map.panel[char]
        print(message.." x"..x.." y"..y)
        game.message.add_message(message, x, y)
      end
    end
  end
  
  game.gfx = {}
  game.gfx.forest = {}
  game.gfx.forest.i = love.graphics.newImage('gfx/forest.png')
  game.gfx.forest.q = {
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(8, 0, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(0, 8, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(8, 8, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(0, 16, 8, 8, game.gfx.forest.i),
    love.graphics.newQuad(8, 16, 8, 8, game.gfx.forest.i),
  }
  game.gfx.home = {}
  game.gfx.home.i = love.graphics.newImage('gfx/home.png')
  game.gfx.home.q = {
    love.graphics.newQuad(0, 0, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(8, 0, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(0, 8, 8, 8, game.gfx.home.i),
    love.graphics.newQuad(8, 8, 8, 8, game.gfx.home.i)
  }

  game.font = love.graphics.newImageFont('gfx/font.png',
    " abcdefghijklmnopqrstuvwxyz",
    1
  )
  love.graphics.setFont(game.font)
  
  generate_simple_map()
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

function generate_simple_map()
  game.map.width = test_map.width
  game.map.height = test_map.height
  game.map.panel = test_map.panel
  local cells = {
    ['.'] = string.byte('.'),
    ['D'] = string.byte('D'),
    ['W'] = string.byte('W') + 0x80,
    ['1'] = string.byte('1') + 0x80 + 0x100,
    ['2'] = string.byte('2') + 0x80 + 0x200,
    ['3'] = string.byte('3') + 0x80 + 0x300,
    ['4'] = string.byte('4') + 0x80 + 0x400,
  }
  
  local offset = 0
  for i = 1, #test_map.string do
    local char = test_map.string:sub(i, i)

    if char == '\n' then
      offset = offset + 1
    else
      game.map.layout[i - offset] = cells[char]
    end
  end
end

function simple_map_canvas()
  local canvas = love.graphics.newCanvas(w, h)
  
  love.graphics.setCanvas(canvas)
  for i = 1, #game.map.layout do
    local tile, quad
    local cell = string.char(bit.band(game.map.layout[i], 0x7F))

    if cell == '.' then
      tile = game.gfx.forest.i
      local rand = math.floor(math.random() * 10) + 1
      local idxs = {1, 1, 1, 1, 3, 3, 3, 2, 4, 6}
      quad = game.gfx.forest.q[idxs[rand]]
    elseif cell == 'W' then
      tile = game.gfx.home.i
      quad = game.gfx.home.q[2]
    elseif cell == 'D' then
      tile = game.gfx.home.i
      quad = game.gfx.home.q[1]
    elseif cell:gmatch('%d') then
      tile = game.gfx.forest.i
      quad = game.gfx.forest.q[5]
    end

    local x = (i - 1) % game.map.width
    local y = math.floor((i - 1) / game.map.width)

    love.graphics.draw(tile, quad, x * 8, y * 8)
  end
  love.graphics.setCanvas()

  return canvas
end

function love.resize()
  -- canvas = simple_grid()
  canvas = simple_map_canvas()
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

  local half_tile = 4 * game.scale -- assuming a tile is 8x8
  local center_x = love.graphics.getWidth() / 2 - half_tile
  local center_y = love.graphics.getHeight() / 2 - half_tile
  local target_cam_x = (center_x - player.px * game.scale)
  local target_cam_y = (center_y - player.py * game.scale)
  game.cam.x = game.cam.x - (game.cam.x - target_cam_x) * game.cam.diff
  game.cam.y = game.cam.y - (game.cam.y - target_cam_y) * game.cam.diff

  game.message.update_messages()
end

function love.draw()
  love.graphics.translate(game.cam.x, game.cam.y)
  love.graphics.draw(canvas, 0, 0, 0, game.scale)
  player.draw()
  game.message.display_messages()
end