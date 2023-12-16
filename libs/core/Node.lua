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
  nodeA.edgesOut[nodeB.ID] = edge
  nodeB.edgesIn[nodeA.ID] = edge
  return nodeA, nodeB
end

local function ConnectInverted(nodeA, nodeB, edge)
  nodeA.edgesIn[nodeB.ID] = edge
  nodeB.edgesOut[nodeA.ID] = edge
  return nodeA, nodeB
end

local function ConnectBothDirections(nodeA, nodeB, edgeA, edgeB)
  nodeA.edgesOut[nodeB.ID] = edgeA
  nodeB.edgesIn[nodeA.ID] = edgeA
  nodeA.edgesIn[nodeB.ID] = edgeB
  nodeB.edgesOut[nodeA.ID] = edgeB
  return nodeA, nodeB
end

local function Disconnect(nodeA, nodeB)
  nodeA.edgesOut[nodeB.ID] = nil
  nodeB.edgesIn[nodeA.ID] = nil
  return nodeA, nodeB
end

local function DisconnectBothDirections(nodeA, nodeB)
  nodeA.edgesOut[nodeB.ID] = nil
  nodeB.edgesIn[nodeA.ID] = nil
  nodeA.edgesIn[nodeB.ID] = nil
  nodeB.edgesOut[nodeA.ID] = nil 
  return nodeA, nodeB
end

local function DisconnectAll(nodeA, nodes)
  local pairsToRemove = {}
  for nodeID, _ in pairs(nodeA.edgesOut) do
    pairsToRemove[#pairsToRemove + 1] = {nodeA.ID, nodeID}
  end
  for nodeID, _ in pairs(nodeA.edgesIn) do
    pairsToRemove[#pairsToRemove + 1] = {nodeID, nodeA.ID}
  end
  for i=1, #pairsToRemove do
    local firstID = pairsToRemove[i][1]
    local secondID = pairsToRemove[i][2]
    nodes[firstID], nodes[secondID] = nodes[firstID]:Disconnect(nodes[secondID])
  end
  return nodes, pairsToRemove
end


function Node:__add(nodeB) -- nodeA -> nodeB, directed edge from A to B
  return Connect(self, nodeB, 0) -- basic edge
end

function Node:__sub(nodeB)
  return Disconnect(self, nodeB)
end

function Node:__mul(nodeB) -- nodeA <-> nodeB, edges in both directions between A and B
  return ConnectBothDirections(self, nodeB, 0) -- basic edge
end

function Node:__div(nodeB) -- nodeA 0 nodeB, cancel all edges between A and B
  return DisconnectBothDirections(self, nodeB)
end

function Node:__eq(nodeB)
  return self.ID == nodeB.ID
end

function Node:__unm() -- do nothing
  return self
end

local function IsConnected(nodeA, nodeB, edge) -- edgeData if not nil has to work on == operator
  local AID = nodeA.ID
  local BID = nodeB.ID
  local AOut = nodeA.edgesOut
  if (AID ~= nil and BID ~=nil and AOut ~= nil) then
    if edge ~= nil then
      return AOut[BID] == edge -- NOT DONE, YET
    else
      return AOut[BID] ~= nil
    end
  end
  return false
end

function Node:GetAllEdges(TypeMatcher, TagsMatcher)
  local selectedEdges = {}
  TypeMatcher = TypeMatcher or function() return true end
  TagsMatcher = TagsMatcher or function() return true end

  for _, edge in pairs(self.edgesOut) do
    if TypeMatcher(edge) and TagsMatcher(edge) then
      selectedEdges[edge.id] = edge
    end
  end

  for _, edge in pairs(self.edgesIn) do
    if TypeMatcher(edge) and TagsMatcher(edge) then
      selectedEdges[edge.id] = edge
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

function Node:RemoveEdge(edgeID)
  self.edgesOut[edgeID] = nil
  self.edgesIn[edgeID] = nil
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

function Node:__tostring()
  local edgesOutString = "out:"
  local edgesInString = "in:"
  for id, edge in pairs(self.edgesOut) do
    edgesOutString = edgesOutString .. id .. "(" .. tostring(edge) ..  "),"
  end
  for id, edge in pairs(self.edgesIn) do
    edgesInString = edgesInString .. id .. "(" .. tostring(edge) ..  "),"
  end
  return 	"POI(ID=" .. tostring(self.ID) ..
    ",nodeType=" .. tostring(self.nodeType) ..
    ",pos=" .. tostring(self.position) .. "," ..
    edgesOutString .. edgesInString ..
    ")"
end

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