local UnrealControl = {}

UnrealControl.RegisterEntityComponent = function(entityID, componentName)
  UnrealControlRegisterEntityComponent(entityID, componentName)
end

UnrealControl.SpawnActor = function(className, position, entityID)
  UnrealControlSpawnActor(className, position, entityID)
end

return UnrealControl
