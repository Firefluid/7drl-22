require "objects.piece"

local maxlen = 5

Rook = Piece:extend()

function Rook:new(x, y, team)
  self.super.new(self, x, y, team)
  self.type = "rook"
end

function Rook:moverandom()
  local positions = {}
  for i=1,maxlen do
    table.insert(positions, {self.x + i, self.y})
    table.insert(positions, {self.x - i, self.y})
    table.insert(positions, {self.x, self.y + i})
    table.insert(positions, {self.x, self.y - i})
  end

  local i = 1
  while i <= #positions do
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

function Rook:step()
  self.super.step(self)

  -- Kill any enemy that can be killed right now
  local directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
  for i,d in ipairs(directions) do
    for l=1,maxlen do
      local x, y = self.x + d[1] * l, self.y + d[2] * l
      if not self:raycast(x, y) then
        local enemy = self.world:getPiece(x, y)
        if enemy and enemy.team ~= self.team then
          self:kill(x, y)
          return
        end
      end
    end
  end

  if self.target then
    -- Try to get close
    local dx = self.target.x - self.x
    local dy = self.target.y - self.y

    if math.abs(dx) >= math.abs(dy) then
      if self:legal(self.x + dx, self.y) then
        self:move(self.x + dx, self.y)
      else
        for i=maxlen,1,-1 do
          local sign = dx / math.abs(dx)
          if self:legal(self.x + i * sign, self.y) then
            self:move(self.x + i * sign, self.y)
          end
        end
      end
    else
      if self:legal(self.x, self.y + dy) then
        self:move(self.x, self.y + dy)
      else
        for i=maxlen,1,-1 do
          local sign = dy / math.abs(dy)
          if self:legal(self.x, self.y + i * sign) then
            self:move(self.x, self.y + i * sign)
          end
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
