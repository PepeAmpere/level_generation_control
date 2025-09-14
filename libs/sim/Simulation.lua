local Simulation = {}
Simulation.__index = Simulation

function Simulation.new(step, startTime)
  local i = setmetatable({}, Simulation) -- make new instance
  i.step = step
  i.startTime = startTime -- outside constant
  i.t = 0

  i.entities = {}
  i.lastEntityIndex = 0
  i.systems = {}
  return i
end

function Simulation.load(simulationData)

  -- print("-----")
  -- for k,v in pairs(simulationData) do
  --   print(k,v)
  -- end

  local i = setmetatable({}, Simulation) -- make new instance
  i.step = simulationData.step
  i.startTime = simulationData.startTime
  i.t = 0

  i.entities = {}
  for entityID, entityData in pairs(simulationData.entities or {}) do
    i.entities[entityID] = Entity.load(entityData)
  end
  i.lastEntityIndex = simulationData.lastEntityIndex

  i.systems = {}
  for systemName, systemData in pairs(simulationData.systems or {}) do
    i.systems[systemName] = Systems[systemName].load(systemData)
  end

  return i
end

function Simulation:Export(logLevel)
  return TableExt.Export(self)
end

function Simulation:GetStep()
  return self.step
end

function Simulation:Update(dSteps)
  self.step = self.step + dSteps
end

function Simulation:GetTime()
  return self.t
end

function Simulation:UpdateTime(t)
  self.t = t - self.startTime
end

function Simulation:AddEntity(params)
  params = params or {}
  IDprefix = params.IDprefix or "e"
  IDsuffix = params.IDsuffix or ""

  local newIDindex = self.lastEntityIndex + 1
  local newID = IDprefix .. newIDindex .. IDsuffix

  if params.ID == nil then
    self.lastEntityIndex = newIDindex
    params.ID = newID
  end

  self.entities[newID] = Entity.new(params)

  return self.entities[newID]
end

function Simulation:AddEntityOfType(entityTypeDef, paramsOverride)
  local params = {}
  for k,v in pairs(entityTypeDef) do
    params[k] = TableExt.DeepCopy(v)
  end
  paramsOverride = paramsOverride or {}
  for k,v in pairs(paramsOverride) do
    params[k] = TableExt.DeepCopy(v)
  end

  local entity = self:AddEntity(params)
  local entityComponents = entityTypeDef.components

  if entityComponents then
    for _, componentData in pairs(entityComponents) do
      for k,v in pairs(componentData) do
        params[k] = TableExt.DeepCopy(v)
      end
      entity:AddComponent(componentData.name, params)
    end
  end

  return entity
end

function Simulation:AddEntityComponent(entityID, componentName, params)
  local allEntities = self:GetEntities()
  local e = allEntities[entityID]
  if e then
    e:AddComponent(componentName, params)
    return true
  end
end

-- generic adder, may not work for certain components
function Simulation:AddEntityComponentValue(entityID, componentName, value)
  local allEntities = self:GetEntities()
  local e = allEntities[entityID]
  if
    e ~= nil and
    e:HasComponent(componentName)
  then
    local c = e:GetComponent(componentName)
    if c.Add then
      return c:Add(value)
    end
  end
end

function Simulation:AddSystem(systemName, params)
  local newSystem = Systems[systemName].new(params)
  self.systems[systemName] = newSystem
  return newSystem
end

function Simulation:GetEntities()
  return self.entities
end

function Simulation:GetEntity(entityID)
  return self.entities[entityID]
end

function Simulation:GetEntityCount()
  local c = 0
  for _,_ in pairs(self.entities) do c = c + 1 end
  return c
end

-- generic getter, may not work for certain components
function Simulation:GetEntityComponentValue(entityID, componentName)
  local allEntities = self:GetEntities()
  local e = allEntities[entityID]
  if
    e ~= nil and
    e:HasComponent(componentName)
  then
    local c = e:GetComponent(componentName)
    if c.Get then
      return c:Get()
    end
  end
end

function Simulation:GetEntityOrder(entityID)
  local parentComponentName = "Parent"
  local ordersComponentName = "ChildrenOrders"
  local allEntities = self:GetEntities()
  local e = allEntities[entityID]
  if
    e ~= nil and
    e:HasComponent(parentComponentName)
  then
    local c = e:GetComponent(parentComponentName)
    local parentID = c:Get()
    local p = allEntities[parentID]
    if
      p ~= nil and
      p:HasComponent(ordersComponentName)
    then
      local co = p:GetComponent(ordersComponentName)
      local orderData = co:GetOrderData(entityID)
      if orderData ~= nil then
        return orderData
      else
        return {}
      end
    end
  end
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

-- generic remover, may not work for certain components
function Simulation:RemoveEntityComponentValue(entityID, componentName, value)
  local allEntities = self:GetEntities()
  local e = allEntities[entityID]
  if
    e ~= nil and
    e:HasComponent(componentName)
  then
    local c = e:GetComponent(componentName)
    if c.Remove then
      return c:Remove(value)
    end
  end
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

-- generic setter, may not work for certain components
function Simulation:SetEntityComponentValue(entityID, componentName, value)
  local allEntities = self:GetEntities()
  local e = allEntities[entityID]
  if 
    e ~= nil and
    e:HasComponent(componentName)
  then
    local c = e:GetComponent(componentName)
    if c.Set then
      c:Set(value)
    end
  end
end

function Simulation:SetChildrenOrders(entityID, orderData)
  local childrenComponentName = "Children"
  local childrenOrdersComponent = "ChildrenOrders"
  local allEntities = self:GetEntities()
  local e = allEntities[entityID]

  if
    e ~= nil and
    e:HasComponent(childrenOrdersComponent) and
    e:HasComponent(childrenComponentName)
  then
    local cOrders = e:GetComponent(childrenOrdersComponent)
    local cChildren = e:GetComponent(childrenComponentName)
    local ch = cChildren:Get()

    for chID, _ in pairs(ch) do
      cOrders:Add(chID, orderData)
    end
  end
end

function Simulation:SetParent(entityID, parentID)
  local parentComponentName = "Parent"
  local childrenComponentName = "Children"
  local allEntities = self:GetEntities()
  local e = allEntities[entityID]
  local p = allEntities[parentID]
  if
    e ~= nil and
    p ~= nil
  then
    local oldParentID

    if e:HasComponent(parentComponentName) then
      local c = e:GetComponent(parentComponentName)
      local oldParentID = c:Get()
    end

    if p:HasComponent(childrenComponentName) then
      local c = p:GetComponent(childrenComponentName)
      c:Add(entityID)
    end

    if oldParentID then
      op = allEntities[oldParentID]
      if op:HasComponent(childrenComponentName) then
        local c = op:GetComponent(childrenComponentName)
        c:Remove(entityID)
      end
    end

    local c = e:GetComponent(parentComponentName)
    c:Set(parentID)
  end
end

return Simulation