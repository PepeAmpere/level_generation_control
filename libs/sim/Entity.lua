-- depends on Components

local Entity = {}
Entity.__index = Entity

function Entity.new(params)
  local i = setmetatable({}, Entity) -- make new instance
  i.ID = params.ID
  i.components = {}
  i.typeName = params.name
  return i
end

function Entity.load(entityData)
  local i = setmetatable({}, Entity) -- make new instance
  i.ID = entityData.ID
  i.components = {}
  for componentName, componentData in pairs(entityData.components) do
    i.components[componentName] = Components[componentName].load(componentData)
  end
  i.typeName = entityData.typeName
  return i
end

function Entity:Export(logLevel)
  local export = {}

  for k,v in pairs(self) do
    if k ~= "components" then
      export[k] = v
    end
    if k == "components" then
      export[k] = {}
      for componentName, component in pairs(v) do
        if component.Export then
          export[k][componentName] = component:Export(logLevel)
        elseif logLevel == "warning" then
          print("WARNING: " .. componentName .. " component has no Export method")
        end
      end
    end
  end

  return export
end

function Entity:AddComponent(componentName, params)
  if
    self.components[componentName] == nil or
    params ~= nil
  then
    self.components[componentName] = Components[componentName].new(params)
  end
  return self.components[componentName]
end

function Entity:GetComponent(componentName) -- reference
  return self.components[componentName]
end

function Entity:GetComponentTypesNames()
  local componentTypesNames = {}
  for componentName, _ in pairs(self.components) do
    componentTypesNames[componentName] = true
  end
  return componentTypesNames
end

function Entity:HasComponent(componentName)
  return self.components[componentName] ~= nil
end

function Entity:GetID()
  return self.ID
end

function Entity:GetTypeName()
  return self.typeName
end

return Entity