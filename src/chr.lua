chrs = {}

function chr(id, x, y)
  local c = {
    x = x,
    y = y,
    px = x * game.scale * 8,
    py = y * game.scale * 8,
    spr_id = id,
    flip = false
  }
  table.insert(chrs, c)
end

function update_chrs(dt)
  local diff = dt * 6
  for i = 1, #chrs do
    local c = chrs[i]
    c.px = c.px - (c.px - c.x * 8) * diff
    c.py = c.py - (c.py - c.y * 8) * diff
  end
end

function draw_chrs()
  local frame = math.floor(game.time * 2) % 2
  for i = 1, #chrs do
    local c = chrs[i]
    local x = c.px * game.scale
    local y = c.py * game.scale
    spr(c.anim + frame, x, y, game.scale, c.flip)
  end
end