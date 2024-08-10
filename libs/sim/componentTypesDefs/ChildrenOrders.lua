local ChildrenOrders = {}
ChildrenOrders.__index = ChildrenOrders

function ChildrenOrders.New()
  local i = setmetatable({}, ChildrenOrders) -- make new instance
  i.childrenTable = {}
  return i
end

function ChildrenOrders:Add(childID, orderData)
  self.childrenTable[childID] = orderData
end

function ChildrenOrders:Get()
  return self.childrenTable
end

function ChildrenOrders:GetOrderData(childID)
  return self.childrenTable[childID]
end

function ChildrenOrders:Remove(childID)
  self.childrenTable[childID] = nil
end

return ChildrenOrders