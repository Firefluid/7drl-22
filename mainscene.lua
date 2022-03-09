require "objects.pawn"
require "objects.piece"
require "objects.player"
require "objects.world"

camx, camy = 0, 0

function drawBackground()
  local w, h = getDimensions()
  for y = -2, h / 16 do
    for x = -2, w / 16 do
      local sx = math.floor(x * 16 + ((-camx + w / 2) % 32))
      local sy = math.floor(y * 16 + ((-camy + h / 2) % 32))
      if (x + y) % 2 == 1 then
        drawTile("floor1", sx, sy)
      else
        drawTile("floor2", sx, sy)
      end
    end
  end
end

function drawPiece(piece, team, x, y, outline)
  local w, h = getDimensions()
  x = x - camx + w / 2
  y = y - 16 - camy + h / 2
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

  love.graphics.resetColor()
end


MainScene = Scene:extend()

function MainScene:new()
  -- Generate world
  self.player = Player(6, 2)
  self.world = World(self.player)
  for i=1,8 do
    self.world:addPiece(Pawn(i + 1, 6 + 2, "black"))
  end
  for i=1,8 do
    self.world:addPiece(Pawn(i + 1, 1 + 2, "white"))
  end
  self.world:sortPieces()

  self.t = 0
  self.deathtime = 0
  self.state = 1
  self.animduration = 0.15

  camx = self.player.x * 16 + 8
  camy = self.player.y * 16 + 4
end

function MainScene:update(dt)
  if self.state == 1 then -- State 1: Wait for player and move whites
    if self.player.alive then
      if self.player:step() then
        for i,v in ipairs(self.world:getPieces()) do
          if v ~= self.player and v.team == "white" then
            v:step()
          end
        end
        self.world:sortPieces()

        self.state = 2
      end
    else
      if love.keyboard.isDown("return") then
        current_scene = MainScene()
      end
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

  if not self.player.alive then
    if self.deathtime == 0 then
      self.deathtime = love.timer.getTime()
    end
  end

  camx = camx + (self.player.x * 16 - camx + 8) * dt * 4
  camy = camy + (self.player.y * 16 - camy + 4) * dt * 4
end

function MainScene:draw()
  love.graphics.setColor(0.9, 0.75, 0.9)

  drawBackground()

  local white_t = 1
  local black_t = 1
  if self.state == 4 then
    black_t = self.t / self.animduration
  elseif self.state == 2 then
    white_t = self.t / self.animduration
  end

  self.world:draw(white_t, black_t)

  -- Death screen
  if self.state == 1 and not self.player.alive then
    local w, h = getDimensions()
    local tw = textWidth("YOU DIED")

    local diff = love.timer.getTime() - self.deathtime

    love.graphics.setColor(0, 0, 0, math.min(diff, 0.5))
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.resetColor()

    love.graphics.setColor(1, 0, 0, math.min(diff, 1))
    drawText((w - tw) / 2, h / 2 - 8, "YOU DIED")
    love.graphics.resetColor()

    if diff > 1.5 then
      diff = diff - 1.5
      tw = textWidth("Press RETURN to restart")

      love.graphics.setColor(0.8, 0.8, 0.8, math.min(diff, 1))
      drawText((w - tw) / 2, h / 2 - 8 + 32, "Press RETURN to restart")
      love.graphics.resetColor()
    end
  end
end
