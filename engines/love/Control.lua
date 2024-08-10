local LoveControl = {}

LoveControl.RegisterEntityComponent = function(entityID, componentName, params)
  OneSim:AddEntityComponent(entityID, componentName, params)
end

LoveControl.SpawnActor = function(className, position)
  -- nothing
end

return LoveControl
