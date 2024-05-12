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
end

function player.update(dt)
  local x, y = 0, 0
  local dx, dy = 0, 0

  if input.lt then x = x - 1 end
  if input.rt then x = x + 1 end
  if input.up then y = y - 1 end
  if input.dn then y = y + 1 end

  local dist = 0.5
  local dist_x = math.abs(player.px - player.x * 8)
  local dist_y = math.abs(player.py - player.y * 8)
  if dist_x < dist and dist_y < dist then
    if x ~= 0 or y ~= 0 then
      dx = dx + x
      dy = dy + y
    end
  else
    if input.lt and not input.prev.lt then dx = dx - 1 end
    if input.rt and not input.prev.rt then dx = dx + 1 end
    if input.up and not input.prev.up then dy = dy - 1 end
    if input.dn and not input.prev.dn then dy = dy + 1 end
  end

  if dx ~= 0 or dy ~= 0 then
    if game.map.is_wall(player.x + dx, player.y + dy) then
      player.px = player.px + dx * 4
      player.py = player.py + dy * 4
      game.map.check_panel(player.x + dx, player.y + dy)
    else
      player.x = player.x + dx
      player.y = player.y + dy
    end
  end

  local diff = dt * 6
  player.px = player.px - (player.px - player.x * 8) * diff
  player.py = player.py - (player.py - player.y * 8) * diff

  if input.lt then player.flip = true end
  if input.rt then player.flip = false end

  if love.keyboard.isScancodeDown('1') then player.anim = PLAYER1 end
  if love.keyboard.isScancodeDown('2') then player.anim = PLAYER2 end
  if love.keyboard.isScancodeDown('3') then player.anim = PLAYER3 end
end

function player.draw()
  local frame = math.floor(game.time * 2) % 2
  
  local x = player.px * game.scale
  local y = player.py * game.scale

  love.graphics.setColor(0, 0, 0, 0.5)
  local rect_scale = 8 * game.scale
  local rect_x = player.x * rect_scale
  local rect_y = player.y * rect_scale
  love.graphics.rectangle('fill', rect_x, rect_y, rect_scale, rect_scale)
  love.graphics.setColor(1, 1, 1)
  spr(player.anim + frame, x, y, game.scale, player.flip)
end
