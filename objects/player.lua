require "objects.piece"

Player = Piece:extend()

function Player:new(x, y)
  self.super.new(self, x, y, "white")
  self.type = "king"
  self.wx = x
  self.wy = y
end

function Player:kill(x, y)
  self.wx = x
  self.wy = y
  self.super.kill(self, x, y)
end

function Player:move(x, y)
  self.wx = x
  self.wy = y
  if not self.super.move(self, x, y) then
    self.world:interact(x, y)
  end
  return true
end

function Player:step()
  self.super.step(self)

  local nx, ny = self.x, self.y
  local makemove = false

  if love.keyboard.isDown("up") then
    ny = self.y - 1
    makemove = true
  elseif love.keyboard.isDown("down") then
    ny = self.y + 1
    makemove = true
  elseif love.keyboard.isDown("left") then
    nx = self.x - 1
    makemove = true
  elseif love.keyboard.isDown("right") then
    nx = self.x + 1
    makemove = true
  elseif love.keyboard.isDown("space") then
    makemove = true
  end

  if makemove then
    local enemy = self.world:getPiece(nx, ny)
    if enemy and enemy.team ~= self.team then
      self:kill(nx, ny)
    else
      self:move(nx, ny)
    end
  end

  return makemove
end

function Player:draw(t)
  local x, y
  if self.wx ~= self.x or self.wy ~= self.y then
    -- Could not move to desired tile, animate bump
    local dx = self.wx - self.x
    local dy = self.wy - self.y
    x = lerp(self.x * 16, (self.x + dx * 3 / 16) * 16, math.sin(t * math.pi))
    y = lerp(self.y * 16, (self.y + dy * 3 / 16) * 16, math.sin(t * math.pi))
  else
    x = lerp(self.px * 16, self.x * 16, t)
    y = lerp(self.py * 16, self.y * 16, t)
  end

  self:drawPiece(self.type, self.team, x, y, self.target ~= nil)
end
