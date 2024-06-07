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
  local width, height = 16, 9
  game.map.canvas = love.graphics.newCanvas(width * 8, height * 8)

  love.graphics.setCanvas(game.map.canvas)
  for y = 0, height do
    for x = 0, width do
      sprite(5, x * 8, y * 8)
    end
  end
  love.graphics.setCanvas()
end
