local img = love.graphics.newImage('gfx.png')
local quad = {}

local w = img:getWidth()
local h = img:getHeight()

for y = 0, h - 1, 8 do
  for x = 0, w - 1, 8 do
    table.insert(quad, love.graphics.newQuad(x, y, 8, 8, img))
  end
end

function spr(n, x, y, scale, flip)
  scale = scale or 1
  local sx = scale
  local ox = 0
  if flip then
    x = x + scale
    sx = -sx
    ox = scale
  end
  love.graphics.draw(img, quad[n], x, y, 0, sx, scale, ox)
end

PLAYER1 = 1
PLAYER2 = 1 + 8
PLAYER3 = 1 + 8 * 2
NPC1    = 1 + 8 * 3
GRASS1  = 3
GRASS2  = 3 + 8
FLOWER1 = 4
FLOWER2 = 4 + 8
FLOWER3 = 4 + 8 * 2
DOOR = 5
WALL = 6
ROOF = 13
MAIL = 14
SIGN = 19