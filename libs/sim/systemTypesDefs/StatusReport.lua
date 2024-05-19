local StatusReport = {}
StatusReport.__index = StatusReport

function StatusReport.New()
local i = setmetatable({}, StatusReport) -- make new instance
  return i
end

function StatusReport:IsEntityValid(entity)
  if entity.components then
    return true
  end
  return false
end

function StatusReport:Run(entities)
  for _, entity in pairs(entities) do
    local componentNames = entity:GetComponentTypesNames()
    for componentName, _ in pairs(componentNames) do
      print(entity:GetID(), componentName)
    end
  end
end

return StatusReport