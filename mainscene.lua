function lerp(x1, x2, t)
  return x1 + t * (x2 - x1)
end

function drawBackground()
  local w, h = getDimensions()
  w = w / 16
  h = h / 16
  for y=0,h do
    for x=0,w do
      if (x + y) % 2 == 1 then
        drawTile("floor1", x * 16, y * 16)
      else
        drawTile("floor2", x * 16, y * 16)
      end
    end
  end
end

function drawPiece(piece, team, x, y, outline)
  y = y - 16
  drawTile(piece .. "_" .. team, x, y)

  -- Draw outline
  if team == "white" then
    love.graphics.setColor(0, 0, 0, 0.75)
  elseif outline then
    love.graphics.setColor(1, 0, 0, 0.75)
  else
    love.graphics.setColor(1, 1, 1, 0.75)
  end

  drawTile(piece .. "_outline", x, y - 1)

  love.graphics.setColor(1, 1, 1)
end

function spiral(x, y, i)
  local ix, iy = 0, 0
  local dx, dy = 0, -1
  for j=1,i do
    if ix == iy or (ix < 0 and ix == -iy) or (ix > 0 and ix == 1-iy) then
      dx, dy = -dy, dx
    end
    ix = ix + dx
    iy = iy + dy
  end

  return ix + x, iy + y
end

function ispiralgen(x, y, i)
  local ix, iy = 0, 0
  local dx, dy = 0, -1
  for j=1,i do
    coroutine.yield(ix + x, iy + y)
    if ix == iy or (ix < 0 and ix == -iy) or (ix > 0 and ix == 1-iy) then
      dx, dy = -dy, dx
    end
    ix = ix + dx
    iy = iy + dy
  end
end

function ispiral(x, y, i)
  return coroutine.wrap(function () ispiralgen(x, y, i) end)
end


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
    self.target = null
  end

  -- Look for potential targets
  if not self.target then
    for x,y in ispiral(self.x, self.y, 225) do
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

function Player:draw(t)
  self.super.draw(self, t)

  love.graphics.setColor(0, 1, 0)
  drawText(0, 0, "x: " .. tostring(self.x))
  drawText(0, 16, "y: " .. tostring(self.y))
  drawText(0, 32, "pieces: " .. tostring(#self.world:getPieces()))
  love.graphics.setColor(1, 1, 1)
end


World = Object:extend()

function World:new()
  self.pieces = {}
end

function World:addPiece(piece)
  table.insert(self.pieces, piece)
  piece:setWorld(self)
end

function World:removePiece(piece)
  for i,v in ipairs(self.pieces) do
    if v == piece then
      table.remove(self.pieces, i)
    end
  end
end

function World:getPieces()
  return self.pieces
end

function World:getPiece(x, y)
  for i,v in ipairs(self.pieces) do
    if v.x == x and v.y == y then
      return v
    end
  end
end

function World:isEmpty(x, y)
  return self:getPiece(x, y) == nil
end

function World:sortPieces()
  table.sort(self.pieces, function(i, j) return j.y > i.y end)
end

MainScene = Scene:extend()

function MainScene:new()
  -- Generate world
  self.player = Player(0, 0)
  self.world = World()
  for i=1,8 do
    self.world:addPiece(Pawn(i, 6, "black"))
  end
  for i=1,8 do
    self.world:addPiece(Pawn(i, 1, "white"))
  end
  self.world:addPiece(self.player)

  self.t = 0
  self.state = 1
  self.time = 0
  self.animduration = 0.2
end

function MainScene:update(dt)
  self.time = self.time + dt

  if self.state == 1 then -- State 1: Wait for player and move whites
    if self.player:step() then
      for i,v in ipairs(self.world:getPieces()) do
        if v ~= self.player and v.team == "white" then
          v:step()
        end
      end
      self.world:sortPieces()

      self.state = 2
    end
  elseif self.state == 2 then -- State 2: Animate whites
    self.t = self.t + dt
    if self.t > self.animduration then
      self.t = 0

      self.state = 3
    end
  elseif self.state == 3 then -- State 3: Move blacks
    for i,v in ipairs(self.world:getPieces()) do
      if v.team == "black" then
        v:step()
      end
    end
    self.world:sortPieces()

    self.state = 4
  elseif self.state == 4 then -- State 4: Animate blacks
    self.t = self.t + dt
    if self.t > self.animduration then
      self.t = 0

      self.state = 1
    end
  end
end

function MainScene:draw()
  for y=1,8 do
    for x=1,8 do
      if (x + y) % 2 == 1 then
        drawTile("floor1", x * 16, y * 16)
      else
        drawTile("floor2", x * 16, y * 16)
      end
    end
  end

  drawBackground()

  local white_t = 1
  local black_t = 1
  if self.state == 4 then
    black_t = self.t / self.animduration
  elseif self.state == 2 then
    white_t = self.t / self.animduration
  end

  for i,v in ipairs(self.world:getPieces()) do
    if v.team == "white" then
      v:draw(white_t)
    else
      v:draw(black_t)
    end
  end
end
