local Children = {}
Children.__index = Children

function Children.New()
  local i = setmetatable({}, Children) -- make new instance
  i.childrenTable = {}
  return i
end

function Children:Add(childID)
  self.childrenTable[childID] = true
end

function Children:Get()
  return self.childrenTable
end

function Children:Remove(childID)
  self.childrenTable[childID] = nil
end

return Children