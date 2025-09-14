local DebugScreen = {}
DebugScreen.__index = DebugScreen
setmetatable(DebugScreen, ComponentBase)

function DebugScreen.new(params)
  local i = setmetatable({}, DebugScreen) -- make new instance
  i.itemsArray = {} -- array

  if params.itemsArray == nil then
    i.itemsArray = {}
  else
    i.itemsArray = params.itemsArray
  end
  return i
end

function DebugScreen:Add(childID, childFn)
  self.itemsArray[childID] = childFn
end

function DebugScreen:Draw(p)
  local itemsArray = self.itemsArray
  for _, ChildFn in ipairs(itemsArray) do
    ChildFn(p)
  end
end

function DebugScreen:IsEmpty()
  return #self.itemsArray == 0
end

function DebugScreen:Remove(childID)
  self.itemsArray[childID] = nil
end

return DebugScreen