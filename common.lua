utf8 = require "utf8"
Object = require "classic"

current_scene = nil

local tileset = {
  meta = {
    file = "data/tileset.png",
    width = 512,
    height = 512
  },
  logo = {0, 32, 32, 32},
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
local ascii_image
local scale = 3
local fullscreen = false

Scene = Object:extend()

function Scene:new()
end

function Scene:load()
end

function Scene:update(dt)
end

function Scene:draw()
end

function getDimensions()
  local w, h = love.graphics.getDimensions()
  w = w / scale
  h = h / scale
  return w, h
end

function drawText(x, y, str)
  for p,c in utf8.codes(str) do
    local ascii = c - 32
    love.graphics.draw(ascii_image,
        love.graphics.newQuad((ascii % 32) * 9, (math.floor(ascii / 32)) * 16,
          9, 16, 288, 48),
        x, y)
    x = x + 9
  end
end

function textWidth(str)
  local w = 0
  for p,c in utf8.codes(str) do
    w = w + 9
  end
  return w
end

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
  ascii_image = love.graphics.newImage("data/ascii.png")
  ascii_image:setFilter("nearest", "nearest")
end

function love.update(dt)
  current_scene:update(dt)
end

function love.draw()
  local transform = love.math.newTransform()
  transform:scale(scale)
  love.graphics.applyTransform(transform)

  current_scene:draw()

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
