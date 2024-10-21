
Components = require("libs.sim.Components")
Entity = require("libs.sim.Entity")
EntityTypes = require(GAME_PATH .. "data.entityTypes")

Simulation = require("libs.sim.Simulation")

-- HARD GLOBAL VAR INTEGRATION WITH GENERIC EVENT FUNCTIONS
-- not support multiple ones until we are clear we need that
OneSim = nil

-- THIS PART WILL BE LATER SERIALIZED
-- OneSim = Simulation.New(0, love.timer.getTime())
OneSim = Simulation.New(0, 0)

local testEntity = OneSim:AddEntityOfType(
  EntityTypes.TestingEntity,
  {IDprefix = "test"}
)

local SAMPLE_SIZE = 19
local MEMORY_SIZE = 5

local memComponent = testEntity:AddComponent(
  "PatternMemoryLast", 
  {
    size = MEMORY_SIZE,
    patternKey = "c"
  }
)
local colors = {"red", "green", "blue", "purple", "black"}

for i=1, SAMPLE_SIZE do
  local selected = colors[math.random(1,#colors)]
  print(i, selected)
  memComponent:Create({
    t = i,
    c = selected
  })
end

--[[ 
print("Mem1: ", memComponent:Get()[1].c, memComponent:Get()[1].t)
print("Mem2: ", memComponent:Get()[2].c, memComponent:Get()[2].t)
print("Mem3: ", memComponent:Get()[3].c, memComponent:Get()[3].t)
]]--

local countsTable, membersCount, uniquePatterns = memComponent:GetCounts()
print("SAMPLE SIZE: " .. SAMPLE_SIZE .. " MEMORY SIZE: " .. MEMORY_SIZE)
print("uniquePatterns: ", uniquePatterns)
print("membersCount: ", membersCount)
for pattern, count in pairs(countsTable) do
  print(pattern .. " " .. count .. " " .. 100* count / membersCount .. "%")
end