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

function drawPiece(piece, team, x, y)
  y = y - 16
  drawTile(piece .. "_" .. team, x, y)

  -- Draw outline
  if team == "white" then
    love.graphics.setColor(0, 0, 0)
  else
    love.graphics.setColor(1, 0, 0)
  end

  drawTile(piece .. "_outline", x, y - 1)

  love.graphics.setColor(1, 1, 1)
end

Piece = Object:extend()

function Piece:new(x, y)
  self.x = x
  self.y = y
end

function Piece:step()
end

function Piece:draw()
end

Player = Piece:extend()

function Player:step()
  if love.keyboard.isDown("up") then
    self.y = self.y - 1
  end
  if love.keyboard.isDown("down") then
    self.y = self.y + 1
  end

  if love.keyboard.isDown("left") then
    self.x = self.x - 1
  end
  if love.keyboard.isDown("right") then
    self.x = self.x + 1
  end
end

function Player:draw()
  drawPiece("king", "white", self.x * 16, self.y * 16)

  love.graphics.setColor(0, 1, 0)
  drawText(0, 0, "x: " .. tostring(self.x))
  drawText(0, 16, "y: " .. tostring(self.y))
  love.graphics.setColor(1, 1, 1)
end

MainScene = Scene:extend()

function MainScene:new()
  self.player = Player(1, 1)
end

function MainScene:update(dt)
  self.player:step()
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

  drawPiece("rook", "white", 1 * 16, 0 * 16)
  drawPiece("rook", "white", 8 * 16, 0 * 16)

  drawPiece("bishop", "white", 2 * 16, 0 * 16)
  drawPiece("bishop", "white", 7 * 16, 0 * 16)

  drawPiece("knight", "white", 3 * 16, 0 * 16)
  drawPiece("knight", "white", 6 * 16, 0 * 16)

  drawPiece("queen", "white", 4 * 16, 0 * 16)
  drawPiece("king", "white", 5 * 16, 0 * 16)

  for i=1,8 do
    drawPiece("pawn", "white", i * 16, 1 * 16)
  end

  for i=1,8 do
    drawPiece("pawn", "black", i * 16, 6 * 16)
  end

  drawPiece("rook", "black", 1 * 16, 7 * 16)
  drawPiece("rook", "black", 8 * 16, 7 * 16)

  drawPiece("bishop", "black", 2 * 16, 7 * 16)
  drawPiece("bishop", "black", 7 * 16, 7 * 16)

  drawPiece("knight", "black", 3 * 16, 7 * 16)
  drawPiece("knight", "black", 6 * 16, 7 * 16)

  drawPiece("queen", "black", 4 * 16, 7 * 16)
  drawPiece("king", "black", 5 * 16, 7 * 16)

  self.player:draw()
end
