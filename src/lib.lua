local image = love.graphics.newImage('gfx.png')
local width, height = image:getDimensions()
local quad = {}

for y = 0, height - 1, 8 do
  for x = 0, width - 1, 8 do
    table.insert(quad, love.graphics.newQuad(x, y, 8, 8, image))
  end
end

function sprite(n, x, y, scale, flip)
  local scale = scale or 1
  local sx, ox = scale, 0
  if flip then
    sx, ox = -scale, 8
  end
  love.graphics.draw(image, quad[n], x, y, 0, sx, scale, ox)
end

function map()
  game.map.canvas = love.graphics.newCanvas(game.map.width * 8, game.map.height * 8)

  love.graphics.setCanvas(game.map.canvas)
  for y = 0, game.map.height do
    for x = 0, game.map.width do
      if game.map.ground[(x + y * game.map.width) + 1] then
        sprite(game.map.ground[(x + y * game.map.width) + 1], x * 8, y * 8)
      else
        table.insert(game.map.ground, ID.GRASS_1)
        sprite(ID.GRASS_1, x * 8, y * 8)
      end

      if game.map.crops[(x + y * game.map.width) + 1] then
        sprite(game.map.crops[(x + y * game.map.width) + 1], x * 8, y * 8)
      else
        table.insert(game.map.crops, nil)
      end
    end
  end
  love.graphics.setCanvas()
end

function action()
  local tile = (game.player.x + game.player.y * game.map.width) + 1
  local id = game.map.ground[tile]
  local crop = game.map.crops[tile]

  if id == ID.GRASS_1 then
    game.map.ground[tile] = ID.SOIL_DRY
  elseif not crop and CROPS[game.player.inv[game.player.inv_cur]] ~= nil then
    game.map.crops[tile] = CROPS[game.player.inv[game.player.inv_cur]].CROP
  elseif crop == ID.CROP_WHEAT_DONE then
    game.map.crops[tile] = nil
    popup(ID.ITEM_WHEAT)
    add_to_inventory(ID.ITEM_WHEAT)
  elseif id == ID.SOIL_DRY then
    game.map.ground[tile] = ID.SOIL_WET
  end
  map()
end

function day()
  for n = 1, #game.map.ground do
    local crop_id = game.map.crops[n]
    local watered = game.map.ground[n] == ID.SOIL_WET

    if watered then
      game.map.ground[n] = ID.SOIL_DRY

      if crop_id ~= ID.CROP_WHEAT_DONE then
        game.map.crops[n] = crop_id + 1
      end
    end
  end
  map()
  print('next day')
end

function popup(id)
  table.insert(game.popup, {
    id = id,
    dur = 50,
    x = game.player.x * 8 * game.scale,
    y = game.player.y * 8 * game.scale - 4 * game.scale,
    oy = game.player.y * 8 * game.scale - 8 * game.scale
  })
end

function update_popup()
  for i, p in pairs(game.popup) do
    if p.dur == 0 then
      table.remove(game.popup, i)
      break
    end

    game.popup[i].y = p.y + (p.oy - p.y) * 0.1
    game.popup[i].dur = p.dur - 1
  end
end

function draw_popup()
  for _, p in pairs(game.popup) do
    sprite(p.id, p.x, p.y, game.scale)
  end
end

function add_to_inventory(id)
  table.insert(game.player.inv, id)
end

function draw_inventory()
  for i, item in pairs(game.player.inv) do
    local x = (i - 1) * 8 * game.scale
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle('fill', x, 0, 8 * game.scale, 8 * game.scale)
    love.graphics.setColor(1, 1, 1)
    sprite(item, x, 0, game.scale)

    if i == game.player.inv_cur then
      sprite(ID.CURSOR, x, 0, game.scale)
    end
  end
end
