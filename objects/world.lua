World = Object:extend()

function World:new()
  self.pieces = {}

  self.layers = {}
  self.layers_pieces = {}
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

function World:draw()
  w, h = getDimensions()
  ox = - camx + w / 2
  oy = - camy + h / 2
  drawTile("wall2", ox, oy - 16)
  drawTile("wall1", ox + 16, oy - 16)
end
