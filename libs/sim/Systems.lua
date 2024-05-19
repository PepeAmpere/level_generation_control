local systemTypes = {
  "AIEval",
  "StatusReport",
}

local systemTypesDefs = {}
for _, systemTypeName in ipairs(systemTypes) do
  systemTypesDefs[systemTypeName] = require("libs.sim.systemTypesDefs." .. systemTypeName)
end

return systemTypesDefs