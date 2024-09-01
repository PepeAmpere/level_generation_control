-- depends on Components

local Entity = {}
Entity.__index = Entity

function Entity.New(params)
  local i = setmetatable({}, Entity) -- make new instance
  i.ID = params.ID
  i.components = {}
  i.typeName = params.name
  return i
end

function Entity:AddComponent(componentName, params)
  if
    self.components[componentName] == nil or
    params ~= nil
  then
    self.components[componentName] = Components[componentName].New(params)
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