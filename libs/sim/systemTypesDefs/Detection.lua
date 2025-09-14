local Detection = {}
Detection.__index = Detection

function Detection.new()
local i = setmetatable({}, Detection) -- make new instance
  return i
end

function Detection:IsEntityValid(entity)
  local position = entity:GetComponent("Position")
  local vision = entity:GetComponent("Vision")
  local visible = entity:GetComponent("Visible")
  if
    (vision == nil and visible == nil) or
    position == nil
  then
    return nil
  else
    return {
      position = position:Get(),
      vision = vision,
      visible = true, -- keep it simple
    }
  end
end

function Detection:Run(entities)
  -- init part, can be cached/properly built later (now calculated each frame)
  local observers = {}
  local targets = {}
  for entityID, entityData in pairs(entities) do
    if entityData.visible and entityData.position then
      targets[entityID] = true
    end
    if entityData.vision and entityData.position then
      observers[entityID] = true
    end
  end

  local visibilityCache = {}
  for observerID, _ in pairs(observers) do
    visibilityCache[observerID] = {}
    local observerRange = entities[observerID].vision:GetRange()
    local observerPosition = entities[observerID].position
    for targetID, _ in pairs(targets) do
      local targetPosition = entities[targetID].position
      if targetPosition:Distance(observerPosition) < observerRange then
        visibilityCache[observerID][targetID] = true
      end
    end
  end

  self.visilityCache = visibilityCache
end

return Detection