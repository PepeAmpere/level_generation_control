-- dependency on
-- * ArrayExt
-- * Edge
-- * Vec3
-- which is loaded externally to reduce environment specific code

local Node = {}
Node.__index = Node

function Node.new(ID, position, nodeType, tags, edgesOut, edgesIn)
  local i = setmetatable({}, Node) -- make new instance
  i.ID = ID
  i.position = position or Vec3(0,0,0) -- Vector3
  i.nodeType = nodeType or "Undefined" -- string
  i.tags = tags or {} -- table: tag => true
  i.edgesOut = edgesOut or {} -- table: edgeID => edge
  i.edgesIn = edgesIn or {} -- table: edgeID => edge
  return i
end

local function Connect(nodeA, nodeB, edge)
  nodeA.edgesOut[edge:GetID()] = edge
  nodeB.edgesIn[edge:GetID()] = edge
  return nodeA, nodeB
end

local function ConnectInverted(nodeA, nodeB, edge)
  nodeA.edgesIn[edge:GetID()] = edge
  nodeB.edgesOut[edge:GetID()] = edge
  return nodeA, nodeB
end

local function ConnectBothDirections(nodeA, nodeB, edgeA, edgeB)
  nodeA.edgesOut[edgeA:GetID()] = edgeA
  nodeB.edgesIn[edgeA:GetID()] = edgeA
  nodeA.edgesIn[nodeB:GetID()] = edgeB
  nodeB.edgesOut[nodeB:GetID()] = edgeB
  return nodeA, nodeB
end

local function Disconnect(nodeA, nodeB, edge)
  nodeA.edgesOut[edge:GetID()] = nil
  nodeB.edgesIn[edge:GetID()] = nil
  return nodeA, nodeB
end

function Node:__eq(nodeB)
  return self.ID == nodeB.ID
end

function Node:__unm() -- do nothing
  return self
end

function Node:GetAllEdges(TypeMatcher, TagsMatcher)
  local selectedEdges = {}
  TypeMatcher = TypeMatcher or function() return true end
  TagsMatcher = TagsMatcher or function() return true end

  for _, edge in pairs(self.edgesOut) do
    if TypeMatcher(edge) and TagsMatcher(edge) then
      selectedEdges[edge:GetID()] = edge
    end
  end

  for _, edge in pairs(self.edgesIn) do
    if TypeMatcher(edge) and TagsMatcher(edge) then
      selectedEdges[edge:GetID()] = edge
    end
  end

  return selectedEdges
end

function Node:GetTags()
  return self.tags
end

function Node:GetType()
  return self.nodeType
end

function Node:HasTag(tag)
  return self.tags[tag]
end

function Node:AddEdgeIn(edge)
  self.edgesIn[edge:GetID()] = edge
end

function Node:AddEdgeOut(edge)
  self.edgesOut[edge:GetID()] = edge
end

function Node:RemoveEdge(edge)
  self.edgesOut[edge:GetID()] = nil
  self.edgesIn[edge:GetID()] = nil
end

function Node:RemoveAllEdges()
  -- need to kill edge references on other nodes
  local allEdges = self:GetAllEdges()
  for _, edge in pairs(allEdges) do
    edge:DisconnectFromNodes()
  end
end

function Node:SetTag(tag)
  self.tags[tag] = true
end

function Node:SetType(nodeType)
  self.nodeType = nodeType
end

function Node:Connect(nodeB, edge)
  return Connect(self, nodeB, edge)
end

function Node:ConnectInverted(nodeB, edge)
  return ConnectInverted(self, nodeB, edge)
end

function Node:ConectBothDirections(nodeB, edgeA, edgeB)
  return ConnectBothDirections(self, nodeB, edgeA, edgeB)
end

function Node:Disconnect(edgeB)
  return Disconnect(self, edgeB)
end

function Node:DisconnectAll(nodes)
  return DisconnectAll(self, nodes)
end

function Node:__lt(nodeB) -- a < b = has b outgoing edge conntecting a?
  return IsConnected(nodeB, self)
end

function Node:IsConnected(nodeB, edge) -- a < b = has b outgoing edge conntecting a?
  return IsConnected(self, nodeB, edge)
end

-- COLLIDING WITH LOVEBIRD
-- function Node:__tostring()
  -- local edgesOutString = "out:"
  -- local edgesInString = "in:"
  -- for id, edge in pairs(self.edgesOut) do
    -- edgesOutString = edgesOutString .. id .. "(" .. tostring(edge) ..  "),"
  -- end
  -- for id, edge in pairs(self.edgesIn) do
    -- edgesInString = edgesInString .. id .. "(" .. tostring(edge) ..  "),"
  -- end
  -- return 	"POI(ID=" .. tostring(self.ID) ..
    -- ",nodeType=" .. tostring(self.nodeType) ..
    -- ",pos=" .. tostring(self.position) .. "," ..
    -- edgesOutString .. edgesInString ..
    -- ")"
-- end

function Node:__concat()
  return tostring(self)
end

function Node:GetDistance(nodeB)
  return (self.position):Distance(nodeB.position)
end

function Node:GetID()
  return self.ID
end

function Node:SetID(ID)
  self.ID = ID
  return self
end

function Node:GetEdgesOut()
  return self.edgesOut
end

function Node:GetEdgesIn()
  return self.edgesIn
end

function Node:GetPosition()
  return self.position
end

function Node:SetPosition(position)
  self.position = position
  return self
end

function Node:GetPositionCoordinates()
  return self.position:GetCoordinates()
end

function Node:GetPositionAsSpringVector()
  return self.position:AsSpringVector()
end

return Node