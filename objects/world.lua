require "classic"
require "objects.pawn"
require "objects.rook"

World = Object:extend()

local function generate_rooms(x, y, w, h, margin)
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

local function outline_rooms(world, rooms)
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

local function inside(x, y, rx, ry, rw, rh)
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

local function carve_linepath(world, rooms, x1, y1, x2, y2)
  if y1 == y2 then
    if x1 > x2 then
      x1, x2 = x2, x1
    end
    for i=x1,x2 do
      local x,y = i,y1
      local room = inside(x, y, rooms)
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
      local room = inside(x, y, rooms)
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

local function randomteam(ratio)
  if math.random() < ratio then
    return "black"
  else
    return "white"
  end
end

local function place_pieces(rooms, ratio)
  local pieces = {}

  for i,r in ipairs(rooms) do
    if i > 1 then
      local rx, ry, rw, rh = unpack(r)
      local team = randomteam(ratio)

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
                Pawn(rx + math.random(rw - 2), ry + iy, randomteam(ratio)))
          end
        else
          for ix=1,count do
            table.insert(pieces,
                Pawn(rx + ix, ry + math.random(rh - 2), randomteam(ratio)))
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

local function generate(width, height)
  local world = {}
  local pieces

  for y=1,height do
    world[y] = {}
  end

  -- Outer walls
  for x = 1, width do
    world[1][x] = "wall1"
    world[height][x] = "wall1"
  end

  for y = 2, height - 1 do
    world[y][1] = "wall1"
    world[y][width] = "wall1"
  end

  -- TODO: Generate interesting world
  -- Ideas:
  -- - Basement
  --   - One or more stairs to upper level
  --   - Many small rooms connected with hallways
  -- - Castle
  --   - One or more exits to outside
  --   - Many large rooms connected with doors
  -- - Outdoors
  --   - Two castles
  --   - Few small rooms with landscape between them
  -- - Enemy Castle
  --   - One or more stairs to upper level
  --   - Many large rooms connected with doors (again)
  -- - Tower
  --   - King, white queen, guards and lots of enemies
  --   - Few large rooms

  -- Generate room spaces
  local rooms = generate_rooms(2, 2, width - 2, height - 2)

  outline_rooms(world, rooms)

  -- Fill underground with stone
  for y=1,height do
    for x=1,width do
      local outside = not inside(x, y, rooms)

      if outside then
        world[y][x] = "wall1"
      end
    end
  end

  -- Connect rooms with doors and halls
  for i,r1 in ipairs(rooms) do
    local x1, y1, w1, h1 = unpack(r1)
    for j,r2 in ipairs(rooms) do
      if r1 ~= r2 and not r2.hasdoor then
        local x2, y2, w2, h2 = unpack(r2)
        local h = false
        local v = false
        if x1 + w1 < x2 or x2 + w2 < x1 then
          h = true
        end
        if y1 + h1 < y2 or y2 + h2 < y1 then
          v = true
        end
        if h and v then
          if math.random(2) == 1 then
            h = false
          else
            v = false
          end
        end

        if h then
          local dx1, dy1, dx2, dy2
          local cx
          dy1 = math.random(y1 + 1, y1 + h1 - 3)
          dy2 = math.random(y2 + 1, y2 + h2 - 3)
          if x1 < x2 then
            dx1 = x1 + w1 - 1
            dx2 = x2
          else
            dx1 = x1
            dx2 = x2 + w2 - 1
          end
          cx = math.random(dx1 + 1, dx2 - 1)

          carve_linepath(world, rooms, dx1, dy1, cx, dy1)
          carve_linepath(world, rooms, cx, dy1, cx, dy2)
          carve_linepath(world, rooms, cx, dy2, dx2, dy2)
        elseif v then
          local dx1, dy1, dx2, dy2
          local cy
          dx1 = math.random(x1 + 1, x1 + w1 - 3)
          dx2 = math.random(x2 + 1, x2 + w2 - 3)
          if y1 < y2 then
            dy1 = y1 + h1 - 1
            dy2 = y2
          else
            dy1 = y1
            dy2 = y2 + h2 - 1
          end
          cy = math.random(dy1 + 1, dy2 - 1)

          carve_linepath(world, rooms, dx1, dy1, dx1, cy)
          carve_linepath(world, rooms, dx1, cy, dx2, cy)
          carve_linepath(world, rooms, dx2, cy, dx2, dy2)
        end

        r1.hasdoor = true
        break
      end
    end
  end

  -- Apply checker pattern to tiles that have two versions
  for y=1,height do
    for x=1,width do
      if world[y][x] and string.sub(world[y][x], -1) == "1" then
        world[y][x] = string.sub(world[y][x], 1, -2)
        if (x + y) % 2 == 0 then
          world[y][x] = world[y][x] .. "1"
        else
          world[y][x] = world[y][x] .. "2"
        end
      end
    end
  end

  -- Place enemies into the rooms
  pieces = place_pieces(rooms, 0.6)

  -- Position player into the first room
  local rx, ry, rw, rh = unpack(rooms[1])
  local playerx = math.random(rx + 1, rx + rw - 3)
  local playery = math.random(ry + 1, ry + rh - 3)

  return world, playerx, playery, pieces
end

function World:new(player)
  self.pieces = {}
  self.player = player
  self.width = 80
  self.height = 80
  self.static = {}
  self.layers = {}

  local pieces
  self.static, self.player.x, self.player.y, pieces
      = generate(self.width, self.height)

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

function World:isEmpty(x, y)
  if x < 1 or y < 1 or x > self.width or y > self.height then
    return false
  end
  return self:getPiece(x, y) == nil and self.static[y][x] == nil
end

function World:interact(x, y)
  local tile = self.static[y][x]

  -- Open doors
  if tile == "door_v" or tile == "door_h" then
    self.static[y][x] = nil
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

function World:draw(white_t, black_t)
  local w, h = getDimensions()

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

  -- Minimap
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
