print("TestGameScreen")

FPS_SIM = 10 -- frames per second for simulation

Entity = require("libs.sim.Entity")
Simulation = require("libs.sim.Simulation")
OneSim = Simulation.New(0, love.timer.getTime())

levelMap = {}
levelMap.nodes = {}

local SIZE = 5

for q = -SIZE, SIZE do
  for r = -SIZE, SIZE do
    for s = -SIZE, SIZE do
      if q + r + s == 0 then
        local nodeID = q .. "|" .. r .. "|" .. s
        levelMap.nodes[nodeID] = Node.new(
          nodeID,
          Hex3(q, r, s),
          "Hex",
          {
            hex = true,
          }
        )
      end
    end
  end
end
