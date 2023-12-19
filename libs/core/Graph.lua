-- dependency on 
-- * Vec3
-- * Edge
-- * Node
-- which is loaded externally to reduce environment specific code

local Graph = {}
Graph.__index = Graph

function Graph.new(nodesList, edgesList)
  local i = setmetatable({}, Graph) -- make new instance

  local nodes = {} -- node key => object reference

  if nodesList == nil then nodesList = {} end
  for _, node in ipairs(nodesList) do
    local nodeID = node:GetID()
    nodes[nodeID] = node
  end

  i.nodes = nodes

  local edges = {} -- edge key => object reference

  if edgesList == nil then edgesList = {} end
  for _, edge in ipairs(edgesList) do
    local edgeID = edge:GetID()
    edges[edgeID] = edge
  end

  i.edges = edges

  return i
end

function Graph:GetNode(nodeID)
  return self.nodes[nodeID]
end

function Graph:GetNodes(TypeMatcher, TagsMatcher)
  local selectedNodes = {}
  TypeMatcher = TypeMatcher or function() return true end
  TagsMatcher = TagsMatcher or function() return true end

  for nodeID, node in pairs(self.nodes) do
    if TypeMatcher(node) and TagsMatcher(node) then
      selectedNodes[nodeID] = node
    end
  end

  return selectedNodes
end

function Graph:RemoveNode(node)
  local nodeID = node:GetID()

  local allEdges = node:GetAllEdges()

  -- remove global references from the edges table
  for edgeID, _ in pairs(allEdges) do
    self.edges[edgeID] = nil
  end

  -- remove in-node refences to the same tables
  node:RemoveAllEdges()
  -- removed node reference itself
  self.nodes[nodeID] = nil
end

return Graph