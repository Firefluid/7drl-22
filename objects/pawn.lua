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
  for i,v in ipairs(positions) do
    if not self.world:isEmpty(v[1], v[2]) then
      table.remove(positions, i)
    end
  end

  local randompos = positions[math.random(#positions)]
  if randompos then
    self:move(randompos[1], randompos[2])
  end
end

function Pawn:step()
  self.super.step(self)

  -- Lose target
  if self.target and (not self.target.alive
      or math.abs(self.x - self.target.x) > 8
      or math.abs(self.y - self.target.y) > 8) then
    self.target = nil
  end

  -- Look for potential targets
  if not self.target then
    for x,y in spiral(self.x, self.y, 225) do
      local piece = self.world:getPiece(x, y)
      if piece and piece.team ~= self.team then
        self.target = piece
        break
      end
    end
  end

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
    -- Try to kill target
    local dx = self.target.x - self.x
    local dy = self.target.y - self.y

    if math.abs(dx) == 1 and math.abs(dy) == 1 then
      -- Go for the kill
      self:kill(self.target.x, self.target.y)
    else
      -- Try to get close
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
