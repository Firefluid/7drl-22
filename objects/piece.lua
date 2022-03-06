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

function Piece:die()
  self.alive = false
  self.world:removePiece(self)
end

function Piece:move(x, y)
  if self.world:isEmpty(x, y) then
    self.x = x
    self.y = y
  end
end

function Piece:kill(x, y)
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
end

function Piece:draw(t)
  local x = lerp(self.px * 16, self.x * 16, t)
  local y = lerp(self.py * 16, self.y * 16, t)

  drawPiece(self.type, self.team, x, y, self.target ~= nil)
end
