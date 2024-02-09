local questTypes = {
  "Escape", -- Path based, depricate
  "FinalPopulator", -- Path based, depricate
}

local questTypesDefs = {}
for _, questTypeName in ipairs(questTypes) do
  questTypesDefs[questTypeName] = require("data.questTypesDefs." .. questTypeName)
end

return {questTypes, questTypesDefs}