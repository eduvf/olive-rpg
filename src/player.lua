player = {
  -- cells
  x = 0,
  y = 0,
  -- pixels
  px = 0,
  py = 0,
  flip = false,
  anim = 1
}

function player.load()
  player.image = love.graphics.newImage('gfx/player.png')
  player.quad = {
    love.graphics.newQuad(0, 0, 8, 8, player.image),
    love.graphics.newQuad(8, 0, 8, 8, player.image),
    love.graphics.newQuad(0, 8, 8, 8, player.image),
    love.graphics.newQuad(8, 8, 8, 8, player.image),
    love.graphics.newQuad(0, 16, 8, 8, player.image),
    love.graphics.newQuad(8, 16, 8, 8, player.image),
    love.graphics.newQuad(0, 24, 8, 8, player.image),
    love.graphics.newQuad(8, 24, 8, 8, player.image),
  }
end

function player.update(dt)
  local x, y = 0, 0

  if input.lt then x = x - 1 end
  if input.rt then x = x + 1 end
  if input.up then y = y - 1 end
  if input.dn then y = y + 1 end

  local dist = 0.5
  local dist_x = math.abs(player.px - player.x * 8)
  local dist_y = math.abs(player.py - player.y * 8)
  if dist_x < dist and dist_y < dist then
    if x ~= 0 or y ~= 0 then
      player.x = player.x + x
      player.y = player.y + y
    end
  else
    if input.lt and not input.prev.lt then player.x = player.x - 1 end
    if input.rt and not input.prev.rt then player.x = player.x + 1 end
    if input.up and not input.prev.up then player.y = player.y - 1 end
    if input.dn and not input.prev.dn then player.y = player.y + 1 end
  end

  local diff = dt * 10
  player.px = player.px - (player.px - player.x * 8) * diff
  player.py = player.py - (player.py - player.y * 8) * diff

  if input.lt then player.flip = true end
  if input.rt then player.flip = false end

  if love.keyboard.isScancodeDown('1') then player.anim = 1 end
  if love.keyboard.isScancodeDown('2') then player.anim = 2 end
  if love.keyboard.isScancodeDown('3') then player.anim = 3 end
  if love.keyboard.isScancodeDown('4') then player.anim = 4 end
end

function player.draw()
  local frame = math.floor(game.time * 2) % 2 + (player.anim * 2 - 1)
  
  local x = player.px * game.scale
  local y = player.py * game.scale
  local sx, sy = game.scale, game.scale
  local ox, oy = 0, 0
  if player.flip then
    x = x + game.scale
    sx = sx * -1
    ox = game.scale
  end

  love.graphics.draw(player.image, player.quad[frame], x, y, 0, sx, sy, ox, oy)
end
