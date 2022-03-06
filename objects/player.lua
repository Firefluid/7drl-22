require "objects.piece"

Player = Piece:extend()

function Player:new(x, y)
  self.super.new(self, x, y, "white")
  self.type = "king"
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
