local componentTypes = {
  "AI",
  "Controller",
  "CtrlGoalMove",
  "CtrlTask",
  "Position",
  "Visible",
  "Vision",
}

local componentTypesDefs = {}
for _, componentTypeName in ipairs(componentTypes) do
  componentTypesDefs[componentTypeName] = require("libs.sim.componentTypesDefs." .. componentTypeName)
end

return componentTypesDefs
