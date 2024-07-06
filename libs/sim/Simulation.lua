local Simulation = {}
Simulation.__index = Simulation

function Simulation.New(step, startTime)
  local i = setmetatable({}, Simulation) -- make new instance
  i.step = step
  i.startTime = startTime -- outside constant
  i.t = 0

  i.entities = {}
  i.lastEntityIndex = 0
  i.systems = {}
  return i
end

function Simulation:Update(dSteps)
  self.step = self.step + dSteps
end

function Simulation:UpdateTime(t)
  self.t = t - self.startTime
end

function Simulation:AddEntity(params)
  params = params or {}

  local newIDindex = self.lastEntityIndex + 1
  local newID = "e" .. newIDindex

  if params.ID == nil then
    self.lastEntityIndex = newIDindex
    params.ID = newID
  end

  self.entities[newID] = Entity.New(params)

  return self.entities[newID]
end

function Simulation:AddEntityOfType(entityTypeDef)
  local params = {}
  for k,v in pairs(entityTypeDef) do
    params[k] = TableExt.DeepCopy(v)
  end

  local entity = self:AddEntity(params)
  local entityComponents = entityTypeDef.components

  if entityComponents then
    for _, componentData in pairs(entityComponents) do
      entity:AddComponent(componentData.name, componentData)
    end
  end

  return entity
end

function Simulation:AddSystem(systemName, params)
  self.systems[systemName] = Systems[systemName].New(params)
end

function Simulation:GetEntities()
  return self.entities
end

function Simulation:GetSystemNames()
  local systemTypesNames = {}
  for systemName, _ in pairs(self.systems) do
    systemTypesNames[systemName] = true
  end
  return systemTypesNames
end

function Simulation:GetSystemEntities(system)
  local entities = self.entities
  local validEntities = {}
  for entityID, entity in pairs(entities) do
    local checkResult = system:IsEntityValid(entity)
    if checkResult then
      validEntities[entityID] = checkResult
    end
  end
  return validEntities
end

function Simulation:RunOneSystem()
end

function Simulation:RunSystems()
  for systemName, system in pairs(self.systems) do
    local validEntities = self:GetSystemEntities(system)
    -- for i, entity in pairs(validEntities) do print(systemName, i, entity:GetID()) end
    system:Run(validEntities)
  end
end

return Simulation