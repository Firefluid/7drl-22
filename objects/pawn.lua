require "objects.piece"

Pawn = Piece:extend()

function Pawn:new(x, y, team)
  self.super.new(self, x, y, team)
  self.type = "pawn"
end

function Pawn:moverandom()
  local positions = {
    {self.x + 1, self.y},
    {self.x - 1, self.y},
    {self.x, self.y + 1},
    {self.x, self.y - 1}
  }

  local i = 1
  while i < #positions do
    if not self:legal(unpack(positions[i])) then
      table.remove(positions, i)
    else
      i = i + 1
    end
  end

  local randompos = positions[math.random(#positions)]
  if randompos then
    self:move(unpack(randompos))
  end
end

function Pawn:step()
  self.super.step(self)

  -- Kill any enemy that can be killed right now
  local offsets = {{1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
  for i,v in ipairs(offsets) do
    local x, y = self.x + v[1], self.y + v[2]
    local enemy = self.world:getPiece(x, y)
    if enemy and enemy.team ~= self.team then
      self:kill(x, y)
      return
    end
  end

  if self.target then
    -- Try to get close
    local dx = self.target.x - self.x
    local dy = self.target.y - self.y

    if math.abs(dx) >= math.abs(dy) then
      if dx > 0 then
        self:move(self.x + 1, self.y)
      else
        self:move(self.x - 1, self.y)
      end
    else
      if dy > 0 then
        self:move(self.x, self.y + 1)
      else
        self:move(self.x, self.y - 1)
      end
    end
  else
    -- Idle behaviour
    if math.random(2) == 2 then
      return -- Stand still
    else
      self:moverandom()
    end
  end
end
