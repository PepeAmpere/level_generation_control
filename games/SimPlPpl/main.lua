print("SimPlPpl main")

FPS_SIM = 10 -- frames per second for simulation

Components = require("libs.sim.Components")
Entity = require("libs.sim.Entity")
EntityTypes = require(GAME_PATH .. "data.entityTypes")

Simulation = require("libs.sim.Simulation")
OneSim = Simulation.new(0, love.timer.getTime())

for i=1, 4 do
  local newEntity = OneSim:AddEntityOfType(EntityTypes.Person,
    {
      IDprefix = "person"
    }
  )
  local positionComponent = newEntity:GetComponent("Position")
  positionComponent:Set(Vec3(i*150, math.random(i*70,i*70+70), 0))

  local BBComponent = newEntity:GetComponent("BB")
  BBComponent:SetVariable("Sense", math.random(1,5))
  BBComponent:SetVariable("Emotion", math.random(1,5))
  BBComponent:SetVariable("Logic", math.random(1,5))
  BBComponent:SetVariable("Memory", math.random(1,5))
  BBComponent:SetVariable("Body", math.random(1,5))
end