print("TestGameScreen")

FPS_SIM = 10 -- frames per second for simulation

Entity = require("libs.sim.Entity")
Simulation = require("libs.sim.Simulation")
OneSim = Simulation.New(0, love.timer.getTime())

correctionPoints = {}
levelMap = {}
levelMap.nodes = {}

local SIZE = 3

for q = -SIZE, SIZE do
  for r = -SIZE, SIZE do
    for s = -SIZE, SIZE do
      if q + r + s == 0 then
        local nodeID = q .. "|" .. r .. "|" .. s
        levelMap.nodes[nodeID] = Node.new(
          nodeID,
          Vec3(q, r, s),
          "Hex",
          {
            hex = true,
          }
        )
        correctionPoints[nodeID] = Vec3(
          math.random()*2 - 1,
          math.random()*2 - 1,
          0
        )
      end
    end
  end
end
