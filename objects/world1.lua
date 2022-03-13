require "objects.world"

World1 = World:extend()

function World1:_generate(width, height)
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

  -- Generate room spaces
  local rooms = self:_generate_rooms(2, 2, width - 2, height - 2)

  self:_outline_rooms(world, rooms)

  -- Fill underground with stone
  for y=1,height do
    for x=1,width do
      local outside = not self:_inside(x, y, rooms)

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

          self:_carve_linepath(world, rooms, dx1, dy1, cx, dy1)
          self:_carve_linepath(world, rooms, cx, dy1, cx, dy2)
          self:_carve_linepath(world, rooms, cx, dy2, dx2, dy2)
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

          self:_carve_linepath(world, rooms, dx1, dy1, dx1, cy)
          self:_carve_linepath(world, rooms, dx1, cy, dx2, cy)
          self:_carve_linepath(world, rooms, dx2, cy, dx2, dy2)
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
  pieces = self:_place_pieces(rooms, 0.6)

  -- Place stairs for the next level
  local rx, ry, rw, rh = unpack(rooms[#rooms])
  local x = math.random(rx + 2, rx + rw - 4)
  local y = math.random(ry + 2, ry + rh - 4)
  world[y][x] = "stairs_up"

  -- Position player into the first room
  rx, ry, rw, rh = unpack(rooms[1])
  local playerx = math.random(rx + 1, rx + rw - 4)
  local playery = math.random(ry + 1, ry + rh - 3)

  world[playery][playerx + 1] = "stairs_down"

  return world, playerx, playery, pieces
end

function World1:draw(white_t, black_t)
  love.graphics.setColor(0.9, 0.75, 0.9)
  self.super.draw(self, white_t, black_t)
end
