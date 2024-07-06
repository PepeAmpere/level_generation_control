FPS_SIM = 10 -- frames per second for simulation

Components = require("libs.sim.Components")
Entity = require("libs.sim.Entity")
EntityTypes = require(GAME_PATH .. "data.entityTypes")

Systems = require("libs.sim.Systems")
Simulation = require("libs.sim.Simulation")

-- HARD GLOBAL VAR INTEGRATION WITH GENERIC EVENT FUNCTIONS
-- not support multiple ones until we are clear we need that
ONE_SIMULATION = nil
OneSim = nil

-- THIS PART WILL BE LATER SERIALIZED
-- OneSim = Simulation.New(0, love.timer.getTime())
OneSim = Simulation.New(0, 0)

local playerEntity = OneSim:AddEntityOfType(EntityTypes.Player)

local crew = {}
for i = 1, 10 do
  local randomPositon = Vec3(0, math.random(-2000,2000), 0)
  local newEntity = OneSim:AddEntityOfType(EntityTypes.Developer)
  local posComponent = newEntity:GetComponent("Position")
  posComponent:Set(randomPositon)
  crew[i] = newEntity
end

local kryssarEntity = OneSim:AddEntityOfType(EntityTypes.Kryssar)

local rats = {}
for i = 1, 5 do
  local randomPositon = Vec3(0, math.random(-800,800), 0)
  local newEntity = OneSim:AddEntityOfType(EntityTypes.Rat)
  local posComponent = newEntity:GetComponent("Position")
  posComponent:Set(randomPositon)
  rats[i] = newEntity
end

-- BELOW JUST LOVE speicifc stuff
--[[
OneSim:AddSystem("AIEval",{})
OneSim:AddSystem("Detection",{})
OneSim:AddSystem("InputHandler",{})
-- OneSim:AddSystem("StatusReport",{})

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

function love.draw()
  love.graphics.setBackgroundColor(192, 192, 192)

  local function DebugStep()
    love.graphics.setColor(0,0,0,255)
    love.graphics.print("Simstep " .. OneSim.step, 400, 240)
    love.graphics.print("Simtime " .. OneSim.t, 400, 260)
  end
  DebugStep()

  local function DrawAllCrew()
    local allEntities = OneSim:GetEntities()
    for entityID, entity in pairs(allEntities) do
      local posComponent = entity:GetComponent("Position")
      if posComponent then
        --print(entityID, posComponent, posComponent:Get())
        Draw.Circle(
          "fill",
          posComponent:Get(),
          4,
          100,
          {255, 255, 255, 255}
        )
      end
    end
  end

  camera:draw(DrawAllCrew)
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
]]--

return {
  math.random()
}