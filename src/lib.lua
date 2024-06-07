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
  elseif not crop then
    game.map.crops[tile] = ID.CROP_WHEAT
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
