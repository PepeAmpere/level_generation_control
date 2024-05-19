FPS_SIM = 10 -- frames per second for simulation

Components = require("libs.sim.Components")
Entity = require("libs.sim.Entity")

Systems = require("libs.sim.Systems")
Simulation = require("libs.sim.Simulation")

OneSim = Simulation.New(0, love.timer.getTime())

local newEntity = OneSim:AddEntity()
newEntity:AddComponent(
  "Position",
  {
    position = Vec3(0,0,0),
  }
)

local secondEntity = OneSim:AddEntity()
secondEntity:AddComponent(
  "AI",
  {}
)

OneSim:AddSystem("AIEval",{})
OneSim:AddSystem("StatusReport",{})

-- BELOW JUST LOVE 2D debugging
-- lovebird = require("libs.lovebird.init")
Colors = require("libs.drawLove.Colors")
Draw = require("libs.drawLove.Draw")
DrawMap = require("libs.drawLove.DrawMap")
Gamera = require("libs.gamera.gamera")

local DRAW_SIZE = 100000
local camera = Gamera.new(-DRAW_SIZE,-DRAW_SIZE,DRAW_SIZE,DRAW_SIZE)
camera:setScale(0.1)

local positionCenterX = 0
local positionCenterY = 0
camera:setWorld(-1800,-1800,1800,1800)
camera:setWindow(0,0,800,600)
camera:setPosition(positionCenterX, positionCenterY)

local UI_STATES = {
  pan = false,
}

function love.load()
end

function love.update(dt)
  if dt < 1/FPS_SIM then
    love.timer.sleep(1/FPS_SIM - dt)
  end

  OneSim:Update(dt)
  OneSim:UpdateTime(love.timer.getTime())
  OneSim:RunSystems()
  -- lovebird.update()
end

function love.draw()
  love.graphics.setBackgroundColor(192, 192, 192)

  local function DebugStep()
    love.graphics.setColor(0,0,0,255)
    love.graphics.print("Simstep " .. OneSim.step, 400, 240)
    love.graphics.print("Simtime " .. OneSim.t, 400, 260)
  end
  DebugStep()
end

function love.mousepressed(x, y, button) 
  if button == 2 then -- right mouse button
    UI_STATES.pan = true
  end
end
function love.mousereleased(x, y, button)
  if button == 2 then -- right mouse button
    UI_STATES.pan = false
  end
end
function love.mousemoved(x, y, dx, dy, istouch)
  if UI_STATES.pan then
    DrawMap.PanMouse(camera, x, y, dx, dy, istouch)
  end
end

function love.wheelmoved(x, y)
  DrawMap.WheelZoom(camera, x, y)
end

function love.keyreleased(key, scancode)
  DrawMap.ControlKeys(camera, key, scancode)
end