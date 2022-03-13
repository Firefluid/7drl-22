require "objects.world"

World2 = World:extend()

function World2:_generate(width, height)
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
  local rooms = self:_generate_rooms(2, 2, width - 2, height - 2, 1)

  self:_outline_rooms(world, rooms)

  -- Create doors
  for i,r1 in ipairs(rooms) do
    local rx, ry, rw, rh = unpack(r1)
    local count = math.random(math.floor(math.min(rw, rh) / 2))

    for j=1,count do
      local side = math.random(4)
      local dx, dy
      local door = nil

      if side == 1 then -- Top
        dx = rx + math.random(rw - 2)
        dy = ry
        door = "door_h"
      elseif side == 2 then -- Right
        dx = rx + rw - 1
        dy = ry + math.random(rh - 2)
        door = "door_v"
      elseif side == 3 then -- Bottom
        dx = rx + math.random(rw - 2)
        dy = ry + rh - 1
        door = "door_h"
      elseif side == 4 then -- Left
        dx = rx
        dy = ry + math.random(rh - 2)
        door = "door_v"
      end

      if math.random(2) == 1 then
        world[dy][dx] = door
      else
        world[dy][dx] = nil
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

function World2:interact(x, y)
  self.super.interact(self, x, y)

  -- Prevent going to nonexistent level (TODO: Implement next level)
  self.cleared = false
end

function World2:draw(white_t, black_t)
  love.graphics.setColor(1, 0.8, 1)
  self.super.draw(self, white_t, black_t)
end
