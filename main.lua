local tileset = {
  meta = {
    file = "data/tileset.png",
    width = 512,
    height = 512
  },
  floor1 = {0, 0, 16, 16},
  floor2 = {16, 0, 16, 16},
  pawn_white = {32, 0, 16, 32},
  pawn_black = {128, 0, 16, 32},
  pawn_outline = {32, 32, 16, 32},
  rook_white = {32 + 16, 0, 16, 32},
  rook_black = {128 + 16, 0, 16, 32},
  rook_outline = {32 + 16, 32, 16, 32},
  bishop_white = {32 + 16 * 2, 0, 16, 32},
  bishop_black = {128 + 16 * 2, 0, 16, 32},
  bishop_outline = {32 + 16 * 2, 32, 16, 32},
  knight_white = {32 + 16 * 3, 0, 16, 32},
  knight_black = {128 + 16 * 3, 0, 16, 32},
  knight_outline = {32 + 16 * 3, 32, 16, 32},
  queen_white = {32 + 16 * 4, 0, 16, 32},
  queen_black = {128 + 16 * 4, 0, 16, 32},
  queen_outline = {32 + 16 * 4, 32, 16, 32},
  king_white = {32 + 16 * 5, 0, 16, 32},
  king_black = {128 + 16 * 5, 0, 16, 32},
  king_outline = {32 + 16 * 5, 32, 16, 32}
}

local scale = 3
local fullscreen = false

function drawTile(tile, x, y)
  love.graphics.draw(tileset.meta.image,
      love.graphics.newQuad(tileset[tile][1], tileset[tile][2],
          tileset[tile][3], tileset[tile][4],
          tileset.meta.width, tileset.meta.height),
      x , y)
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

function drawBackground()
  local w, h = love.graphics.getDimensions()
  w = w / scale / 16
  h = h / scale / 16
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

function love.load()
  tileset.meta.image = love.graphics.newImage(tileset.meta.file)
  tileset.meta.image:setFilter("nearest", "nearest")
end

function love.draw()
  local transform = love.math.newTransform()
  transform:scale(scale)
  love.graphics.applyTransform(transform)

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

  love.graphics.origin()
end

function love.resize(w, h)
  scale = math.max(math.min(math.floor(w / 240), math.floor(h / 136)), 1)
end

function love.keypressed(key, scancode, isrepeat)
  if scancode == "f11" then
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen)
  end
end
