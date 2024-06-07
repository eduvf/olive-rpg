local image = love.graphics.newImage('gfx.png')
local width, height = image:getDimensions()
local quad = {}

for y = 0, height - 1, 8 do
  for x = 0, width - 1, 8 do
    table.insert(quad, love.graphics.newQuad(x, y, 8, 8, image))
  end
end

function sprite(n, x, y, flip)
  local sx, ox = game.scale, 0
  if flip then
    sx, ox = -game.scale, 8
  end
  love.graphics.draw(image, quad[n], x, y, 0, sx, game.scale, ox)
end
