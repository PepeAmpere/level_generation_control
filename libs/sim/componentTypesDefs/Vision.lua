local Vision = {}
Vision.__index = Vision

function Vision.New(params)
  local i = setmetatable({}, Vision) -- make new instance
  i.range = params.range
  i.visibleEntities = {}
  return i
end

function Vision:SetVisibleEntities(entities)
  self.visibleEntities = entities
end

function Vision:GetRange()
  return self.range
end

return Vision