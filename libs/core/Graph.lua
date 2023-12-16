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

function Graph:GetNodes()
  return self.nodes -- copy or reference?
end

function Graph:RemoveEdge(edge)
  local edgeID = edge:GetID()
  local nodesFrom = edge:GetNodesFrom()
  for nodeID, _ in pairs(nodesFrom) do
    local node = self.nodes[nodeID]
    if node then 
      node:RemoveEdge(edgeID) 
    end
  end

  local nodesTo = edge:GetNodesTo()
  for nodeID, _ in pairs(nodesTo) do
    local node = self.nodes[nodeID]
    if node then 
      node:RemoveEdge(edgeID) 
    end
  end

  self.edges[edgeID] = nil
end

function Graph:RemoveNode(node)
  local nodeID = node:GetID()
  local edgesToRemove = {}

  for _, edge in pairs(node.edgesOut) do
    edgesToRemove[edge:GetID()] = edge
  end

  for _, edge in pairs(node.edgesIn) do
    edgesToRemove[edge:GetID()] = edge
  end

  for _, edge in pairs(edgesToRemove) do
    self:RemoveEdge(edge)
  end

  self.nodes[nodeID] = nil
end


return Graph