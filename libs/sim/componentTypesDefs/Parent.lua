local Parent = {}
Parent.__index = Parent
setmetatable(Parent, ComponentBase)

function Parent.new()
  local i = setmetatable({}, Parent) -- make new instance
  i.parentID = nil
  return i
end

function Parent:Get()
  return self.parentID
end

function Parent:Set(parentID)
  self.parentID = parentID
end

return Parent