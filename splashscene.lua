require "common"
require "mainscene"

SplashScene = Scene:extend()

function SplashScene:new()
  self.time = 0
  self.stage = 1
  self.stagetime = {0.5, 1.5, 0.5, 1.5, 0.5}
end

function SplashScene:update(dt)
  self.time = self.time + dt

  if self.time > self.stagetime[self.stage] then
    self.time = self.time - self.stagetime[self.stage]
    self.stage = self.stage + 1
  end

  if self.stage > #self.stagetime
      or love.keyboard.isDown("return") then
    -- Go to next stage
    current_scene = MainScene()
  end
end

function SplashScene:draw()
  local w, h = getDimensions()
  love.graphics.clear()

  if self.stage == 2 then
    drawTile("logo", w / 2 - 16, h / 2 - 24)
    local tw = textWidth("firefluid")
    drawText((w - tw) / 2, h / 2 + 16, "firefluid")
  elseif self.stage == 4 then
    local tw = textWidth("Dame's Chess")
    drawText((w - tw) / 2, h / 2 - 8, "Dame's Chess")
  end
end
