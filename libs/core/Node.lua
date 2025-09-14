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
  i.position = position -- Vec3 or Hex3
  i.nodeType = nodeType or "Undefined" -- string
  i.tags = tags or {} -- table: tag => true
  i.edgesOut = edgesOut or {} -- table: edgeID => edge
  i.edgesIn = edgesIn or {} -- table: edgeID => edge
  return i
end

function Node.load(nodeData)
  local i = setmetatable({}, Node) -- make new instance
  i.ID = nodeData.ID
  i.position = load(nodeData.position)()
  i.nodeType = nodeData.nodeType
  i.tags = nodeData.tags
  i.edgesOut = {}
  i.edgesIn = {}
  return i
end

function Node.loadEdges(nodeID, nodeData, graph)
  local node = graph:GetNode(nodeID)
  node.edgesOut = {}
  for edgeID, _ in pairs(nodeData.edgesOut or {}) do
    node.edgesOut[edgeID] = graph:GetEdge(edgeID)
  end
  node.edgesIn = {}
  for edgeID, _ in pairs(nodeData.edgesIn or {}) do
    node.edgesIn[edgeID] = graph:GetEdge(edgeID)
  end
  return node
end

function Node:Export(logLevel)
  return TableExt.Export(self)
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
  return self:GetID() == nodeB:GetID()
end

function Node:__unm() -- do nothing
  return self
end

function Node:AddEdgeIn(edge)
  self.edgesIn[edge:GetID()] = edge
end

function Node:AddEdgeOut(edge)
  self.edgesOut[edge:GetID()] = edge
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

function Node:GetAllEdges(Matcher, inOut)
  local inOutMode = inOut or "all"
  local selectedEdges = {}
  Matcher = Matcher or function() return true end

  if
    inOutMode == "all" or
    inOutMode == "out"
  then
    for _, edge in pairs(self.edgesOut) do
      if Matcher(edge) then
        selectedEdges[edge:GetID()] = edge
      end
    end
  end

  if
    inOutMode == "all" or
    inOutMode == "in"
  then
    for _, edge in pairs(self.edgesIn) do
      if Matcher(edge) then
        selectedEdges[edge:GetID()] = edge
      end
    end
  end

  return selectedEdges
end

function Node:GetTags()
  return self.tags
end

function Node:GetTagValue(tag)
  if self:HasTag(tag) then
    return self.tags[tag]
  end
end

function Node:GetType()
  return self.nodeType
end

function Node:IsTypeOf(nodeType)
  return self.nodeType == nodeType
end

function Node:IsEqual(nodeB)
  return self:GetID() == nodeB:GetID()
end

function Node:HasTag(tag)
  return self.tags[tag] ~= nil
end

function Node:RemoveAllEdges()
  -- need to kill edge references on other nodes
  local allEdges = self:GetAllEdges()
  for _, edge in pairs(allEdges) do
    edge:DisconnectFromNodes()
  end
end

function Node:RemoveEdge(edge)
  self.edgesOut[edge:GetID()] = nil
  self.edgesIn[edge:GetID()] = nil
end

function Node:RemoveTag(tag)
  self.tags[tag] = nil
end

function Node:TagRDFSLook(
    NodeMatcher, NodeUpdater,
    EdgeMatcher, EdgeUpdater, edgesInOut,
    EndMatcher
)
  NodeUpdater(self)
  if EndMatcher(self) then
    return Path.new({self})
  end

  local nodesToTry = {}
  local edgesByNode = {}

  local edges = self:GetAllEdges(EdgeMatcher, edgesInOut)
  for _, edge in pairs(edges) do
    local newNodes
    if edgesInOut == "out" then
      newNodes = edge:GetNodesTo()
    else
      newNodes = edge:GetNodesFrom()
    end
    for _, node in pairs(newNodes) do
      nodesToTry[#nodesToTry + 1] = node
      edgesByNode[node:GetID()] = edge
    end
  end

  local function TryNode(
    node, edge,
    NodeMatcher, NodeUpdater,
    EdgeMatcher, EdgeUpdater, edgesInOut,
    EndMatcher
  )
    if NodeMatcher(node) then
      EdgeUpdater(edge)
      return node:TagRDFSLook(
        NodeMatcher, NodeUpdater,
        EdgeMatcher, EdgeUpdater, edgesInOut,
        EndMatcher
      )
    end
  end

  -- first three random
  local passed = false
  local lastResult
  if #nodesToTry > 0 then
    for i=1, math.min(3, #nodesToTry) do
      local nodeIndex = math.random(#nodesToTry)
      local selectedNode = nodesToTry[nodeIndex]
      local selectedEdge = edgesByNode[selectedNode:GetID()]
      -- print(self:GetID(), "=> Random try " .. selectedNode:GetID(), nodeIndex, "of", #nodesToTry)
      lastResult = TryNode(
        selectedNode, selectedEdge,
        NodeMatcher, NodeUpdater,
        EdgeMatcher, EdgeUpdater, edgesInOut,
        EndMatcher
      )
      if lastResult then
        passed = true
        break
      end
    end

    if not passed then
      for i=1,#nodesToTry do
        -- print(self:GetID(), " => Ordered try " .. nodesToTry[i]:GetID(), i, "from", #nodesToTry)
        lastResult = TryNode(
          nodesToTry[i], edgesByNode[nodesToTry[i]:GetID()],
          NodeMatcher, NodeUpdater,
          EdgeMatcher, EdgeUpdater, edgesInOut,
          EndMatcher
        )
        if lastResult then
          passed = true
          break
        end
      end
    end
  end

  if lastResult then
    return lastResult:AppendNode(self) -- path expected
  end
end

function Node:SetTag(tag)
  self.tags[tag] = true
end

function Node:SetTagValue(tag, value)
  self.tags[tag] = value
end

function Node:SetType(nodeType)
  self.nodeType = nodeType
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