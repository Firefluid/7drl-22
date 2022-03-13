require "classic"
require "objects.pawn"
require "objects.rook"

World = Object:extend()

function World:_generate_rooms(x, y, w, h, margin)
  local m = margin or 2
  local stack = {}
  local rooms = {}

  stack[1] = {x, y, w, h}
  while #stack > 0 do
    local sx, sy, sw, sh = unpack(table.remove(stack, 1))
    local rw = math.random(6, math.min(sw, 18))
    local rh = math.random(6, math.min(sh, 18))
    local rx, ry = math.random(sx, sx + sw - rw), math.random(sy, sy + sh - rh)

    if sw >= 6 and sh >= 6 then
      table.insert(rooms, {rx, ry, rw, rh})

      if sw >= sh then
        table.insert(stack, {sx + m, sy + m, rx - sx - 2 * m, sh - 2 * m})
        table.insert(stack,
            {rx + rw + m, sy + m, sw - (rx - sx) - rw - 2 * m, sh - 2 * m})
        table.insert(stack, {x + m, sy + m, rw - 2 * m, ry - sy - 2 * m})
        table.insert(stack,
            {rx + m, ry + rh + m, rw - 2 * m, sh - (ry - sy) - rh - 2 * m})
      else
        table.insert(stack, {sx + m, sy + m, sw - 2 * m, ry - sy - 2 * m})
        table.insert(stack,
            {sx + m, ry + rh + m, sw - 2 * m, sh - (ry - sy) - rh - 2 * m})
        table.insert(stack, {sx + m, ry + m, rx - sx - 2 * m, rh - 2 * m})
        table.insert(stack,
            {rx + rw + m, ry + m, sw - (rx - sx) - rw - 2 * m, rh - 2 * m})
      end
    end
  end

  return rooms
end

function World:_outline_rooms(world, rooms)
  for i,r in ipairs(rooms) do
    local x, y, w, h = unpack(r)

    for ix = x, x + w - 1 do
      world[y][ix] = "wall1"
      world[y + h - 1][ix] = "wall1"
    end

    for iy = y + 1, y + h - 2 do
      world[iy][x] = "wall1"
      world[iy][x + w - 1] = "wall1"
    end
  end
end

function World:_inside(x, y, rx, ry, rw, rh)
  if type(rx) == "table" then
    local rooms = rx

    for i,r in ipairs(rooms) do
      rx, ry, rw, rh = unpack(r)
      if x >= rx and y >= ry and x < rx + rw and y < ry + rh then
        return r
      end
    end

    return nil
  else
    return x >= rx and y >= ry and x < rx + rw and y < ry + rh
  end
end

function World:_carve_linepath(world, rooms, x1, y1, x2, y2)
  if y1 == y2 then
    if x1 > x2 then
      x1, x2 = x2, x1
    end
    for i=x1,x2 do
      local x,y = i,y1
      local room = self:_inside(x, y, rooms)
      local tile = nil
      if room  then
        local rx, ry, rw, rh = unpack(room)
        if (x == rx or x == rx + rw - 1)
            and (world[y - 1][x] and world[y + 1][x]) then
          tile = "door_v"
        end
      end
      world[y][x] = tile
    end
  else
    if y1 > y2 then
      y1, y2 = y2, y1
    end
    for i=y1,y2 do
      local x,y = x1,i
      local room = self:_inside(x, y, rooms)
      local tile = nil
      if room  then
        local rx, ry, rw, rh = unpack(room)
        if (y == ry or y == ry + rh - 1)
            and (world[y][x - 1] and world[y][x + 1]) then
          tile = "door_h"
        end
      end
      world[y][x] = tile
    end
  end
end

function World:_randomteam(ratio)
  if math.random() < ratio then
    return "black"
  else
    return "white"
  end
end

function World:_place_pieces(rooms, ratio)
  local pieces = {}

  for i,r in ipairs(rooms) do
    if i > 1 and i < #rooms then
      local rx, ry, rw, rh = unpack(r)
      local team = self:_randomteam(ratio)

      if rw >= 9 and rh >= 9 and math.random(3) ==  1 then
        table.insert(pieces, Pawn(rx + 5, ry + 3, team))
        table.insert(pieces, Pawn(rx + 3, ry + 5, team))
        table.insert(pieces, Pawn(rx + 7, ry + 5, team))
        table.insert(pieces, Pawn(rx + 5, ry + 7, team))
      elseif math.random(3) == 1 then -- A group of pawns
        local count = math.random(math.min(rw, rh, 8))
        if rw < rh then
          for iy=1,count do
            table.insert(pieces,
                Pawn(rx + math.random(rw - 2), ry + iy,
                    self:_randomteam(ratio)))
          end
        else
          for ix=1,count do
            table.insert(pieces,
                Pawn(rx + ix, ry + math.random(rh - 2),
                    self:_randomteam(ratio)))
          end
        end
      else -- Single piece
        local x = math.random(rx + 1, rx + rw - 3)
        local y = math.random(ry + 1, ry + rh - 3)

        local type = math.random(2)
        local piece
        if type == 1 then
          piece = Pawn(x, y, team)
        else
          piece = Rook(x, y, team)
        end

        table.insert(pieces, piece)
      end
    end
  end

  return pieces
end

function World:_generate(width, height)
  local world = {}
  local pieces = {}
  local playerx, playery = 0, 0
  return world, playerx, playery, pieces
end

function World:new(player)
  self.cleared = false
  self.player = player
  self.pieces = {}
  self.width = 80
  self.height = 80
  self.static = {}
  self.layers = {}

  local pieces
  self.static, self.player.x, self.player.y, pieces
      = self:_generate(self.width, self.height)

  for i,p in ipairs(pieces) do
    self:addPiece(p)
  end

  self:addPiece(self.player)

  self:sortPieces()
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

function World:isEmpty(x, y)
  if x < 1 or y < 1 or x > self.width or y > self.height then
    return false
  end
  return self:getPiece(x, y) == nil and self.static[y][x] == nil
end

function World:interact(x, y)
  local tile = self.static[y][x]

  if tile == "door_v" or tile == "door_h" then -- Open doors
    self.static[y][x] = nil
  elseif tile == "stairs_up" then -- Go to the next level
    self.cleared = true
  end
end

-- Draws the background checker pattern with manual camera translation to
-- retain screen space and only draw visible tiles
function World:_drawBackground()
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

function World:_drawMinimap()
  for y=1,self.height do
    for x=1,self.width do
      if self.static[y][x] then
        love.graphics.setColor(1, 0, 0, 0.5)
      else
        love.graphics.setColor(0, 0, 0, 0.5)
      end

      love.graphics.rectangle("fill", x, y, 1, 1)

      love.graphics.resetColor()
    end
  end

  for i,p in ipairs(self.pieces) do
    love.graphics.setColor(0, 1, 0, 0.5)

    love.graphics.rectangle("fill", p.x, p.y, 1, 1)

    love.graphics.resetColor()
  end
end

function World:draw(white_t, black_t)
  local w, h = getDimensions()

  self:_drawBackground()

  love.graphics.push("transform")
  love.graphics.translate(math.floor(-camx + w / 2), math.floor(-camy + h / 2))

  for y=1,self.height do
    for x=1,self.width do
      local tile = self.static[y][x]
      if tile then
        drawTile(tile, x * 16, y * 16 - 16)
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

  love.graphics.pop()
end
