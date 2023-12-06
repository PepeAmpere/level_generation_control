local questTypes = {
  "GetLighter",
  "Escape",
}

local questTypesDefs = {}
for i, questTypeName in ipairs(questTypes) do
  questTypesDefs[questTypeName] = require("data.questTypesDefs." .. questTypeName)
end

return questTypesDefs