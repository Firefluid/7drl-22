require "classic"

Piece = Object:extend()

function Piece:new(x, y, team)
  self.px = x
  self.py = y
  self.x = x
  self.y = y
  self.team = team
  self.type = nil -- Needs to be set by subclass
  self.alive = true
end

function Piece:setWorld(world)
  self.world = world
end

function Piece:legal(x, y)
  return self.world:isEmpty(x, y) and not self:raycast(x, y)
end

-- Modified Bresenham's line algorithm
-- (does not check first and last point
-- since those are the pieces themselves)
function Piece:raycast(x, y)
  local ix, iy = self.x, self.y
  local dx, dy = math.abs(x - self.x), -math.abs(y - self.y)
  local sx, sy
  if self.x < x then sx = 1 else sx = -1 end
  if self.y < y then sy = 1 else sy = -1 end
  local err = dx + dy
  local e2

  while true do
    e2 = 2 * err
    if e2 >= dy then
      err = err + dy
      ix = ix + sx
    end
    if e2 <= dx then
      err = err + dx
      iy = iy + sy
    end

    if ix == x and iy == y then
      return false
    end

    if not self.world:isEmpty(ix, iy) then
      return true
    end
  end
end

function Piece:die()
  self.alive = false
  self.world:removePiece(self)
end

function Piece:move(x, y)
  if self.world:isEmpty(x, y) then
    self.x = x
    self.y = y
    return true
  else
    return false
  end
end

function Piece:kill(x, y)
  if self:raycast(x, y) then
    return
  end

  local piece = self.world:getPiece(x, y)
  if piece then
    piece:die()
  end

  self.x = x
  self.y = y
end

function Piece:step()
  self.px = self.x
  self.py = self.y

  -- Lose/forget target
  if self.target then
    if not self.target.alive then
      self.target = nil
    elseif math.abs(self.x - self.target.x) >= 8
        or math.abs(self.y - self.target.y) >= 8 then
      self.target = nil
    elseif math.random(5) == 1
        and self:raycast(self.target.x, self.target.y) then
      self.target = nil
    end
  end

  -- Look for potential targets
  if not self.target then
    for x,y in spiral(self.x, self.y, 225) do -- Spiral a 8x8 field
      local piece = self.world:getPiece(x, y)
      if piece and piece.team ~= self.team and not self:raycast(x, y) then
        self.target = piece
        break
      end
    end
  end
end

function Piece:_drawPiece(piece, team, x, y, outline)
  y = y - 16

  drawTile(piece .. "_" .. team, x, y)

  -- Draw outline
  if team == "white" then
    love.graphics.setColor(0, 0, 0, 0.75)
  elseif outline then
    love.graphics.setColor(1, 0, 0,
        map(math.sin(love.timer.getTime() * 4 * math.pi), -1, 1, 0.5, 1))
  else
    love.graphics.setColor(1, 1, 1, 0.75)
  end

  drawTile(piece .. "_outline", x, y - 1)

  love.graphics.resetColor()
end

function Piece:draw(t)
  local x = lerp(self.px * 16, self.x * 16, t)
  local y = lerp(self.py * 16, self.y * 16, t)

  self:_drawPiece(self.type, self.team, x, y, self.target ~= nil)
end
