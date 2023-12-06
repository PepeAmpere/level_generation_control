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

-- @description Provides array of Path nodes
function Path:GetNodes()
  return self.nodesOrderedList -- shall it be copy? this is reference and maybe thats actually wanted...
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