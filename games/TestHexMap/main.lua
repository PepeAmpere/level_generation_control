print("TestGameScreen")

FPS_SIM = 10 -- frames per second for simulation

Components = require("libs.sim.Components")
Entity = require("libs.sim.Entity")
EntityTypes = require(GAME_PATH .. "data.entityTypes")

Simulation = require("libs.sim.Simulation")
OneSim = Simulation.New(0, love.timer.getTime())

HexTypesDefs = require(GAME_PATH .. "data.hexTypes")
HexTreeTilesDefs = require(GAME_PATH .. "data.hexTreeTiles")

HexBase = require("libs.map.HexBase")
HexMap = require("libs.map.HexMap")
HexTurtle = require("libs.map.HexTurtle")

SensorTypesDefs = require(GAME_PATH .. "data.sensorTypes")

local GetNodeTags = function()
  return {
    hex = true,
    hexTypeName = TableExt.GetRandomValue(HexTypesDefs).name,
    hexTreeTile = TableExt.GetRandomValue(HexTreeTilesDefs).name,
    --color = {math.random(),math.random(),math.random()}
  }
end

local rootTags = GetNodeTags()
levelMap = HexMap.new(0, 0, 0, rootTags)

local SIZE = 5
local GAP_MULT = 1
HEX_SIZE = 100

for q = -GAP_MULT*SIZE, GAP_MULT*SIZE, GAP_MULT do
  for r = -GAP_MULT*SIZE, GAP_MULT*SIZE, GAP_MULT do
    for s = -GAP_MULT*SIZE, GAP_MULT*SIZE, GAP_MULT do
      if
        q + r + s == 0 and
        not (q == 0 and r == 0 and s == 0)
      then
        local hexCoords = Hex3(q, r, s, HEX_SIZE)
        local nodeID = hexCoords:ToKey()
        local nodeTags = GetNodeTags()
        levelMap.nodes[nodeID] = Node.new(
          nodeID,
          hexCoords,
          "Hex",
          nodeTags
        )

        local x, y = hexCoords:ToPixel()
        local newEntity = OneSim:AddEntityOfType(
          EntityTypes.Person, {
            IDprefix = "person",
            position = Vec3(-y, x, 0)
          }
        )
        OneSim:AddEntityOfType(
          EntityTypes.Wagon, {
            IDprefix = "wagon",
            position = Vec3(-y, x, 0) + Vec3(math.random(-50, 50), math.random(-50, 50),0)
          }
        )
      end
    end
  end
end
