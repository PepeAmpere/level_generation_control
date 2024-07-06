local LoveControl = {}

LoveControl.RegisterEntityComponent = function(entityID, componentName, params)
  local allEntities = ONE_SIMULATION:GetEntities()
  local e = allEntities[entityID]
  if e then
    e:AddComponent(componentName, params)
    return true
  end
end

LoveControl.SpawnActor = function(className, position)
  -- nothing
end

return LoveControl
