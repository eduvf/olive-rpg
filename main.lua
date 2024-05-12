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

  require 'src/gfx'

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
      local width = game.font:getWidth(message.text) * game.scale
      local x = message.x - width / 2 + game.scale * 4
      local y = message.y - game.scale * 2
      local bg_x = x - game.scale
      local bg_y = y
      local bg_w = width + game.scale
      local bg_h = game.font:getHeight() * game.scale
      if message.duration < total then
        alpha = message.duration / total
      end
      love.graphics.setColor(29 / 256, 43 / 256, 83 / 256, alpha)
      love.graphics.rectangle('fill', bg_x, bg_y, bg_w, bg_h)
      love.graphics.setColor(1, 1, 1, alpha)
      love.graphics.print(message.text, x, y, 0, game.scale)
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
        -- print(message.." x"..x.." y"..y)
        game.message.add_message(message, x, y)
      end
    end
  end

  game.font = love.graphics.newImageFont('gfx/font.png',
    " !\"#$%&'()*+,-./" ..
    "0123456789:;<=>?" ..
    "@ABCDEFGHIJKLMNO" ..
    "PQRSTUVWXYZ[\\]^_" ..
    "`abcdefghijklmno" ..
    "pqrstuvwxyz{|}~",
    1
  )
  love.graphics.setFont(game.font)
  
  generate_simple_map()
  canvas = simple_map_canvas()

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
    local cell = string.char(bit.band(game.map.layout[i], 0x7F))

    local s = GRASS1
    if cell == '.' then
      local flowers = {FLOWER1, FLOWER2, FLOWER3}
      if math.random() > 0.5 then
        s = GRASS2
      elseif math.random() > 0.5 then
        s = flowers[math.floor(math.random() * #flowers) + 1]
      end
    elseif cell == 'W' then
      s = WALL
    elseif cell == 'D' then
      s = DOOR
    elseif cell:gmatch('%d') then
      s = SIGN
    end

    local x = (i - 1) % game.map.width
    local y = math.floor((i - 1) / game.map.width)

    spr(s, x * 8, y * 8)
  end
  love.graphics.setCanvas()

  return canvas
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