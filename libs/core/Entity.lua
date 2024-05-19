local Entity = {}
Entity.__index = Entity

function Entity.New()
  local i = setmetatable({}, Entity) -- make new instance
  return i
end

return Entity