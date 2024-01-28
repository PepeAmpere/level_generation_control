-- dependency on
-- * Vec3
-- * Node
-- which is loaded externally to reduce environment specific code

local Path = {}
Path.__index = Path
setmetatable(Path, Graph)

-- @description Creates new Path
-- @argument orderedNodes [array] i => Node
-- @return new Path instance
function Path.new(orderedNodes)
  local i = setmetatable({}, Path) -- make new instance

  local nodesOrderedList = {} -- index => node key
  local nodeIDtoIndex = {} -- node key => index
  local nodes = {} -- node key => object reference

  if orderedNodes == nil then orderedNodes = {} end
  for ni, node in ipairs(orderedNodes) do
    local nodeID = node:GetID()
    nodesOrderedList[ni] = nodeID
    nodeIDtoIndex[nodeID] = ni
    nodes[nodeID] = node
  end

  i.nodesOrderedList = nodesOrderedList
  i.nodeIDtoIndex = nodeIDtoIndex
  i.nodes = nodes

  return i
end

function Path:AppendNode(node)
  local nodeID = node:GetID()
  local newIndex = #self.nodesOrderedList+1
  self.nodesOrderedList[newIndex] = nodeID
  self.nodeIDtoIndex[nodeID] = newIndex
  self.nodes[nodeID] = node
  return self
end

function Path:Export()
  local exportedObject = {}

  -- export all keys automatically unless specifically handled
  for k,v in pairs(self) do
    if k == "nodes" then
      exportedObject[k] = {}
      for nodeID, _ in pairs(v) do
        exportedObject[k][nodeID] = true
      end
    else
      exportedObject[k] = v
    end
  end

  return exportedObject
end

function Path:FindNode(Matcher) -- implicitly from start
  for _, nodeID in ipairs(self.nodesOrderedList) do
    local node = self.nodes[nodeID]
    if Matcher(node) then return node end
  end
  return nil
end

function Path:FindNodePair(Matcher, distance) -- implicitly from start
  if #self.nodesOrderedList < distance + 1 then return nil end
  for i=1, #self.nodesOrderedList-distance do
    local nodeAID = self.nodesOrderedList[i]
    local nodeBID = self.nodesOrderedList[i+distance]
    local nodeA = self.nodes[nodeAID]
    local nodeB = self.nodes[nodeBID]
    if Matcher(nodeA, nodeB) then return nodeA, nodeB end
  end
  return nil
end

-- @description Provides nodeKey => node object table
function Path:GetNodes()
  return self.nodes
end

function Path:GetStartNode()
  local firstNodeID = self.nodesOrderedList[1]
  return self.nodes[firstNodeID]
end

function Path:GetNodesCount()
  return #self.nodesOrderedList
end

-- @description Provides an array of nodes positions in format (x1, y1, x2, y2, ...)
-- @return array of position coordinates, 2x nodes-count long
function Path:GetNodesCoords2D()
  local nodesCoords2D = {}
  for _, nodeID in ipairs(self.nodesOrderedList) do
    local nodePosition = self.nodes[nodeID]:GetPosition()
    nodesCoords2D[#nodesCoords2D + 1] = nodePosition:X()
    nodesCoords2D[#nodesCoords2D + 1] = nodePosition:Y()
  end
  return nodesCoords2D
end

function Path:IsValid()
  if
    self.nodesOrderedList ~= nil and
    self.nodeIDtoIndex ~= nil and
    self.nodes ~= nil
  then
    return true
  end
  return false
end



return Path