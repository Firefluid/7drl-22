require "common"

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

MainScene = Object:extend()

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
end

MainScene:implement(Scene)

SplashScene = Object:extend()

function SplashScene:new()
  self.time = 0
  self.stage = 1
end

function SplashScene:update(dt)
  self.time = self.time + dt

  if self.stage == 1 then
    if self.time > 0.5 then
      self.time = self.time - 0.5
      self.stage = 2
    end
  elseif self.stage == 2 then
    if self.time > 1.5 then
      self.time = self.time - 1.5
      self.stage = 3
    end
  elseif self.stage == 3 then
    if self.time > 0.5 then
      -- Go to next stage
      current_scene = MainScene()
    end
  end
end

function SplashScene:draw()
  local w, h = getDimensions()
  local tw = textWidth("firefluid")

  love.graphics.clear()

  if self.stage == 2 then
    drawTile("logo", w / 2 - 16, h / 2 - 16)
    drawText((w - tw) / 2, h / 2 + 24, "firefluid")
  end
end

SplashScene:implement(Scene)

current_scene = SplashScene()
