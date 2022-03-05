tileset = {
  meta = {
    file = "data/tileset.png",
    width = 512,
    height = 512
  },
  floor1 = {0, 0, 16, 16},
  floor2 = {16, 0, 16, 16},
  pawn = {32, 0, 16, 32}
}

function drawTile(tile, x, y)
  love.graphics.draw(tileset.meta.image,
      love.graphics.newQuad(tileset[tile][1], tileset[tile][2],
          tileset[tile][3], tileset[tile][4],
          tileset.meta.width, tileset.meta.height),
      x , y)
end

function love.load()
  tileset.meta.image = love.graphics.newImage(tileset.meta.file)
  tileset.meta.image:setFilter("nearest", "nearest")
end

function love.draw()
  local transform = love.math.newTransform()
  transform:scale(2)
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

  drawTile("pawn", 32, 32 - 16)

  love.graphics.origin()

  love.graphics.print("Hello World", 0, 0)
end
