-- runtime dependency on
-- * Node

local Edge = {}
Edge.__index = Edge

function Edge.new(id, nodesFrom, nodesTo, edgeType, tags)
  local i = setmetatable({}, Edge) -- make new instance
  i.id = id
  i.nodesFrom = nodesFrom or {} -- array, index => node (to keep the order for multiedges)
  i.nodesTo = nodesTo or {} -- array, index => node (to keep the order for multiedges)
  i.edgeType = edgeType or "Undefined"
  i.tags = tags or {}
  return i
end

function Edge.load(edgeData, graph)
  local i = setmetatable({}, Edge) -- make new instance
  i.id = edgeData.id
  i.edgeType = edgeData.edgeType
  i.tags = edgeData.tags

  i.nodesFrom = edgeData.nodesFrom
  i.nodesTo = edgeData.To
  i.nodesFrom = {}
  for nodeID, _ in pairs(edgeData.nodesFrom or {}) do
    i.nodesFrom[nodeID] = graph:GetNode(nodeID)
  end
  i.nodesTo = {}
  for nodeID, _ in pairs(edgeData.nodesTo or {}) do
    i.nodesTo[nodeID] = graph:GetNode(nodeID)
  end
  return i
end

function Edge:Export()
  return TableExt.Export(self)
end

function Edge:DisconnectFromNodes()
  for _, node in ipairs(self.nodesTo) do
    node:RemoveEdge(self)
  end
  for _, node in ipairs(self.nodesFrom) do
    node:RemoveEdge(self)
  end
end

function Edge:Export()
  local exportedObject = {}

  -- export all keys automatically unless specifically handled
  for k,v in pairs(self) do
    if k == "nodesFrom" or k == "nodesTo" then
      exportedObject[k] = {}
      for nodeID, node in ipairs(v) do
        exportedObject[k][nodeID] = node:GetID()
      end
    else
      --exportedObject[k] = v
    end
  end

  return exportedObject
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

function Edge:RemoveTag(tag)
  self.tags[tag] = nil
end

function Edge:SetTag(tag)
   self.tags[tag] = true
end

function Edge:SetType(edgeType)
  self.edgeType = edgeType
end

return Edge