require "objects.player"
require "objects.world1"
require "objects.world2"

camx, camy = 0, 0

MainScene = Scene:extend()

function MainScene:new(world)
  self.level = world or 1
  self.animduration = 0.15
  self.deathtime = 0
  self.player = Player(0, 0)
  self.state = 1
  self.t = 0
  self.world = nil

  if self.level == 1 then
    self.world = World1(self.player)
  elseif self.level == 2 then
    self.world = World2(self.player)
  end

  camx = self.player.x * 16 + 8
  camy = self.player.y * 16 + 4
end

function MainScene:update(dt)
  -- Animation state machine
  if self.state == 1 then -- State 1: Wait for player and move whites
    if self.player.alive then
      if self.player:step() then
        for i,v in ipairs(self.world:getPieces()) do
          if v ~= self.player and v.team == "white" then
            v:step()
          end
        end
        self.world:sortPieces()

        self.state = 2
      end
    else
      if love.keyboard.isDown("return") then
        current_scene = MainScene()
      end
    end
  elseif self.state == 2 then -- State 2: Animate whites
    self.t = self.t + dt
    if self.t > self.animduration then
      self.t = 0

      self.state = 3
    end
  elseif self.state == 3 then -- State 3: Move blacks
    for i,v in ipairs(self.world:getPieces()) do
      if v.team == "black" then
        v:step()
      end
    end
    self.world:sortPieces()

    self.state = 4
  elseif self.state == 4 then -- State 4: Animate blacks
    self.t = self.t + dt
    if self.t > self.animduration then
      self.t = 0

      self.state = 1
    end
  end

  -- Load next world
  if self.world.cleared then
    current_scene = MainScene(self.level + 1)
  end

  -- Start death screen animation
  if not self.player.alive then
    if self.deathtime == 0 then
      self.deathtime = love.timer.getTime()
    end
  end

  -- Update camera
  camx = camx + (self.player.x * 16 - camx + 8) * dt * 4
  camy = camy + (self.player.y * 16 - camy + 4) * dt * 4
end

function MainScene:draw()
  -- Calculate animation offsets for each team
  local white_t = 1
  local black_t = 1
  if self.state == 4 then
    black_t = self.t / self.animduration
  elseif self.state == 2 then
    white_t = self.t / self.animduration
  end

  -- Draw world
  self.world:draw(white_t, black_t)

  -- Death screen
  if self.state == 1 and not self.player.alive then
    local w, h = getDimensions()
    local tw = textWidth("YOU DIED")

    local diff = love.timer.getTime() - self.deathtime

    love.graphics.setColor(0, 0, 0, math.min(diff, 0.5))
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.resetColor()

    love.graphics.setColor(1, 0, 0, math.min(diff, 1))
    drawText((w - tw) / 2, h / 2 - 8, "YOU DIED")
    love.graphics.resetColor()

    if diff > 1.5 then
      diff = diff - 1.5
      tw = textWidth("Press RETURN to restart")

      love.graphics.setColor(0.8, 0.8, 0.8, math.min(diff, 1))
      drawText((w - tw) / 2, h / 2 - 8 + 32, "Press RETURN to restart")
      love.graphics.resetColor()
    end
  end
end
