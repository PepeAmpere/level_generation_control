-- depends on Components

local Entity = {}
Entity.__index = Entity

function Entity.New(params)
  local i = setmetatable({}, Entity) -- make new instance
  i.ID = params.ID 
  i.components = {}
  return i
end

function Entity:AddComponent(componentName, params)
  self.components[componentName] = Components[componentName].New(params)
end

function Entity:GetComponentTypesNames()
  local componentTypesNames = {}
  for componentName, _ in pairs(self.components) do
    componentTypesNames[componentName] = true
  end
  return componentTypesNames
end

function Entity:GetID()
  return self.ID
end

return Entity