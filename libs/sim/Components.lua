local componentTypes = {
  "AI",
  "Children",
  "ChildrenOrders",
  "Controller",
  "CtrlGoalMove",
  "CtrlTask",
  "Parent",
  "Position",
  "Visible",
  "Vision",
}

local componentTypesDefs = {}
for _, componentTypeName in ipairs(componentTypes) do
  componentTypesDefs[componentTypeName] = require("libs.sim.componentTypesDefs." .. componentTypeName)
end

return componentTypesDefs
