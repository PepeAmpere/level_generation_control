local systemTypes = {
  "AIEval",
  "Detection",
  "InputHandler",
  "StatusReport",
}

local systemTypesDefs = {}
for _, systemTypeName in ipairs(systemTypes) do
  systemTypesDefs[systemTypeName] = require("libs.sim.systemTypesDefs." .. systemTypeName)
end

-- manually added item
systemTypesDefs["HexMap"] = HexMap

-- indexed array part of the definition
local systemTypesArray = {}
for systemName, _ in pairs(systemTypesDefs) do
  local newDefID = #systemTypesArray+1
  systemTypesDefs[systemName].name = systemName
  systemTypesDefs[systemName].defID = newDefID
  systemTypesArray[#systemTypesArray+1] = systemTypesDefs[hexType]
end

for i,v in ipairs(systemTypesArray) do systemTypesDefs[i] = v end

return systemTypesDefs