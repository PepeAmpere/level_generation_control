-- dependency on 
-- * Vec3
-- which is loaded externally to reduce environment specific code

local Node = {}
Node.__index = Node

function Node.new(id, position, nodeType, tags, edgesOut, edgesIn)
  local i = setmetatable({}, Node) -- make new instance
  i.id = id
  i.position = position or Vec3(0,0,0) -- Vector3
  i.nodeType = nodeType or "Undefined" -- string
  i.tags = tags or {} -- table: tag => true
  i.edgesOut = edgesOut or {} -- table: edgeID => true
  i.edgesIn = edgesIn or {} -- table: edgeID => true
  return i
end

function Node:GetAllEdges(TypeMatcher, TagsMatcher)
  local selectedEdges = {}
  TypeMatcher = TypeMatcher or function() return true end
  TagsMatcher = TagsMatcher or function() return true end

  for _, edge in pairs(self.edgesOut) do
    if TypeMatcher(edge) and TagsMatcher(edge) then
      selectedEdges[edge.id] = true
    end
  end

  for _, edge in pairs(self.edgesIn) do
    if TypeMatcher(edge) and TagsMatcher(edge) then
      selectedEdges[edge.id] = true
    end
  end

  return selectedEdges
end

function Node:GetID()
  return self.id
end

function Node:GetPosition()
  return self.position
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

return Node