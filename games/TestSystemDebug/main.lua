print("TestSystemDebug")

FPS_SIM = 30 -- frames per second for simulation

Components = require("libs.sim.Components")
Entity = require("libs.sim.Entity")

Systems = require("libs.sim.Systems")

Simulation = require("libs.sim.Simulation"); -- require("libs.sim.test.Simulation_test")
OneSim = Simulation.new(0, love.timer.getTime())

AUTOPLAY = false
lastStep = 0

SIMPLE_NODES = {
  {
    name = "furnace",
    position = Vec3(10, 150, 0),
    values = {
      min = 0,
      max = 80,
      current = 50,
    },
  },
  {
    name = "room temperature",
    position = Vec3(300, 100, 0),
    values = {
      min = 10,
      max = 30,
      current = 22,
    },
  },
  {
    name = "outside temperature",
    position = Vec3(600, 150, 0),
    values = {
      min = 10,
      max = 30,
      current = 14,
    },
  },
}
SIMPLE_EDGES = {
  {
    name = "heat",
    startNode = "furnace",
    startNodeIndex = 1, -- temporary
    endNode = "room temperature",
    endNodeIndex = 2, -- temporary
    values = {
      functionType = 1,
      input1 = "1",
      input1Value = 1,
    },
  },
  {
    name = "heat loses",
    startNode = "room temperature",
    startNodeIndex = 2, -- temporary
    endNode = "outside temperature",
    endNodeIndex = 3, -- temporary
    values = {
      functionType = 1,
      input1 = "1",
      input1Value = 1,
    },
  }
}
SIMPLE_FUNCTIONS = {
  simpleLinearPipe = function(edge)
    local cap = edge.values.input1
    local startNode = SIMPLE_NODES[edge.startNodeIndex] -- temporary reference
    local endNode = SIMPLE_NODES[edge.endNodeIndex] -- temporary reference

    local stockSource = startNode.values.current
    local stockTarget = endNode.values.current

    if
      stockSource > 0 and -- stock is lower in source
      (stockTarget + 1) <= endNode.values.max -- target is not full
    then
      local stockDiff = math.min(stockSource, cap, endNode.values.max - stockTarget)
      startNode.values.current = startNode.values.current - stockDiff
      endNode.values.current = endNode.values.current + stockDiff
    end
  end,

  simpleHeatPipe = function(edge)
    local cap = edge.values.input1
    local startNode = SIMPLE_NODES[edge.startNodeIndex] -- temporary reference
    local endNode = SIMPLE_NODES[edge.endNodeIndex] -- temporary reference

    local stockSource = startNode.values.current
    local stockTarget = endNode.values.current

    if
      stockSource > stockTarget and -- stock is lower in source
      (stockTarget + 1) <= endNode.values.max -- target is not full
    then
      local stockDiff = math.min(
        math.max(stockSource - stockTarget, 0), 
        cap, 
        endNode.values.max - stockTarget
      )
      startNode.values.current = startNode.values.current - stockDiff
      endNode.values.current = endNode.values.current + stockDiff
    end
  end,

  simpleHeatLoss = function(edge)
    local cap = edge.values.input1
    local startNode = SIMPLE_NODES[edge.startNodeIndex] -- temporary reference
    local endNode = SIMPLE_NODES[edge.endNodeIndex] -- temporary reference

    local stockSource = startNode.values.current
    local stockTarget = endNode.values.current

    if
      stockSource > stockTarget and -- stock is lower in source
      (stockTarget + 1) <= endNode.values.max -- target is not full
    then
      local stockDiff = math.min(
        math.max(stockSource - stockTarget, 0), 
        cap, 
        endNode.values.max - stockTarget
      )
      startNode.values.current = startNode.values.current - stockDiff
    end
  end
}
LIST_OF_FUNCTIONS = {}
for k,v in pairs(SIMPLE_FUNCTIONS) do LIST_OF_FUNCTIONS[#LIST_OF_FUNCTIONS+1] = k end

HISTORICAL_DATA = {}

function SimulateAllTransfers()
  local edges = SIMPLE_EDGES
  for _, edge in ipairs(edges) do
    SIMPLE_FUNCTIONS[LIST_OF_FUNCTIONS[edge.values.functionType]](edge)
  end
end