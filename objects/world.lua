World = Object:extend()

function World:new()
  self.pieces = {}
  self.width = 10
  self.height = 10
  self.static = {}
  self.layers = {}

  for y=1,self.height do
    self.static[y] = {}
  end

  for x = 1, self.width do
    self.static[1][x] = "wall1"
    self.static[self.height][x] = "wall1"
  end

  for y = 2, self.height - 1 do
    self.static[y][1] = "wall1"
    self.static[y][self.width] = "wall1"
  end

  for y=1,self.height do
    for x=1,self.width do
      if self.static[y][x] and string.sub(self.static[y][x], -1) == "1" then
        self.static[y][x] = string.sub(self.static[y][x], 1, -2)
        if (x + y) % 2 == 1 then
          self.static[y][x] = self.static[y][x] .. "1"
        else
          self.static[y][x] = self.static[y][x] .. "2"
        end
      end
    end
  end
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
  return self:getPiece(x, y) == nil and self.static[y][x] == nil
end

function World:sortPieces()
  table.sort(self.pieces, function(i, j) return j.y > i.y end)

  self.layers = {}
  for i,p in ipairs(self.pieces) do
    if not self.layers[p.y] then
      self.layers[p.y] = {}
    end

    table.insert(self.layers[p.y], p)
  end
end

function World:draw(white_t, black_t)
  local w, h = getDimensions()
  local ox = - camx + w / 2
  local oy = - camy + h / 2

  for y=1,self.height do
    for x=1,self.width do
      local tile = self.static[y][x]
      if tile then
        drawTile(tile, ox + x * 16, oy + y * 16 - 16)
      end
    end

    if self.layers[y] then
      for i,p in ipairs(self.layers[y]) do
        if p.team == "white" then
          p:draw(white_t)
        else
          p:draw(black_t)
        end
      end
    end
  end
end
