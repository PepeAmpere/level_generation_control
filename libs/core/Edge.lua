local Edge = {}
Edge.__index = Edge

function Edge.new(id, nodesFrom, nodesTo, edgeType, tags)
  local i = setmetatable({}, Edge) -- make new instance
  i.id = id
  i.nodesFrom = nodesFrom or {}
  i.nodesTo = nodesTo or {}
  i.edgeType = edgeType or "Undefined"
  i.tags = tags or {}
  return i
end

function Edge:GetID()
  return self.id
end

function Edge:GetNodesFrom()
  return self.nodesFrom
end

function Edge:GetNodesTo()
  return self.nodesTo
end

function Edge:GetTags()
  return self.tags
end

function Edge:GetType()
  return self.edgeType
end

function Edge:HasTag(tag)
  return self.tags[tag]
end

function Edge:IsTypeOf(edgeType)
  return self.edgeType == edgeType
end

function Edge:SetTag(tag)
   self.tags[tag] = true
end

function Edge:SetType(edgeType)
  self.edgeType = edgeType
end

return Edge