print("TestGameScreen")

FPS_SIM = 10 -- frames per second for simulation

Components = require("libs.sim.Components")
Entity = require("libs.sim.Entity")
EntityTypes = require(GAME_PATH .. "data.entityTypes")

Simulation = require("libs.sim.Simulation")
OneSim = Simulation.New(0, love.timer.getTime())

NodeTypes = require(GAME_PATH .. "data.nodeTypes")

HexBase = require("libs.map.HexBase")
HexMap = require("libs.map.HexMap")
HexTurtle = require("libs.map.HexTurtle")

local GetNodeTags = function()
  return {
    hex = true,
    nodeType = TableExt.GetRandomValue(NodeTypes),
    --color = {math.random(),math.random(),math.random()}
  }
end

local rootTags = GetNodeTags()
levelMap = HexMap.new(0, 0, 0, rootTags)

local SIZE = 5
SCALE = 100

for q = -SIZE, SIZE do
  for r = -SIZE, SIZE do
    for s = -SIZE, SIZE do
      if
        q + r + s == 0 and
        not (q == 0 and r == 0 and s == 0)
      then
        local nodeID = q .. "|" .. r .. "|" .. s
        local nodeTags = GetNodeTags()
        local hexCoords = Hex3(q, r, s)
        levelMap.nodes[nodeID] = Node.new(
          nodeID,
          hexCoords,
          "Hex",
          nodeTags
        )

        local x, y = hexCoords:ToPixel(SCALE)
        local newEntity = OneSim:AddEntityOfType(
          EntityTypes.Person, {
            IDprefix = "person",
            position = Vec3(-y, x, 0)
          }
        )
      end
    end
  end
end
