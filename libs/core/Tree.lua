-- dependency on
-- * Vec3
-- * Node
-- which is loaded externally to reduce environment specific code

local Tree = {}
Tree.__index = Tree
setmetatable(Tree, Graph)

-- @description Creates new Tree
-- @return new Tree instance
function Tree.new(rootNode)
  local i = setmetatable({}, Tree) -- make new instance

  local rootNodeID = rootNode:GetID()
  i.nodes = {
    [rootNodeID] = rootNode,
  } -- nodeID => node object reference

  i.children = {} -- nodeIDs => array of nodeIDs, if not empty (= order matters)
  i.parents = {} -- nodeID => parent nodeID - all nodes except root have a parent

  i.rootNodeID = rootNodeID

  return i
end

function Tree:AddNode(node, parent) -- only simple addition as a leaf, both params node-objects
  local nodeID = node:GetID()
  local parentID = parent:GetID()

  self.nodes[nodeID] = node
  self.parents[nodeID] = parentID

  -- update or make new array for children
  if not self.children[parentID] then
    self.children[parentID] = {}
  end
  self.children[parentID][#self.children[parentID] + 1] = nodeID
end

function Tree:GetNodeChildren(nodeID)
  return self.children[nodeID]
end

function Tree:GetLeafNodes()
  local leafNodes = {}
  for nodeID, node in pairs(self.nodes) do
    local children = self.children[nodeID]
    if children == nil then
      leafNodes[nodeID] = node
    end

    -- error check/unit test
    if children ~= nil and #children == 0 then
      assert(false, "Tree:GetLeafNodes(): Node " .. nodeID .. " has children array but no children")
    end
  end
  return leafNodes -- nodeID => node object reference
end

function Tree:GetMaxDepth()
  local rootNodeID = self.rootNodeID

  local function RecLookup(tree, nodeID, depth)
    local childrenOfNode = tree:GetNodeChildren(nodeID) or {}
    local currentMaxDepth = depth
    local deepestNodeID = nodeID

    for i=1, #childrenOfNode do
      local lastMaxDepth, deepNodeID = RecLookup(tree, childrenOfNode[i], depth + 1)
      if lastMaxDepth > currentMaxDepth then
        currentMaxDepth = lastMaxDepth
        deepestNodeID = deepNodeID
      end
    end

    return currentMaxDepth, deepestNodeID
  end

  local depth, nodeID = RecLookup(self, rootNodeID, 0)
  return depth, self.nodes[nodeID]
end

function Tree:GetNode(nodeID)
  return self.nodes[nodeID]
end

function Tree:GetNodes()
  local nodes = {}

  for nodeID, node in pairs(self.nodes) do
    nodes[nodeID] = node
  end

  return nodes
end

function Tree:GetNodesCountPerType()
  local nodes = self.nodes
  local typesRegister = {}

  for _, node in pairs(nodes) do
    local nodeType = node:GetType()
    if typesRegister[nodeType] == nil then
      typesRegister[nodeType] = 1
    else
      typesRegister[nodeType] = typesRegister[nodeType] + 1
    end
  end

  return typesRegister
end

function Tree:GetParentOf(node)
  local parents = self.parents
  local parentID = parents[node:GetID()]

  return self.nodes[parentID]
end

function Tree:GetParentOfID(nodeID)
  local parents = self.parents
  local parentID = parents[nodeID]

  return self.nodes[parentID]
end

function Tree:GetRootNode()
  local rootNodeID = self.rootNodeID
  return self.nodes[rootNodeID]
end

function Tree:HasNode(node)
  return node ~= nil and
    node.GetID ~= nil and
    self.nodes[node:GetID()] ~= nil
end

function Tree:HasNodeID(nodeID)
  return self.nodes[nodeID] ~= nil
end

function Tree:RemoveNode(node)
  print("Tree:RemoveNode() not implemented, but added to prevent call of inherited graph-version of the method")
end

function Tree:RunSearchAndTransform(Matcher, Transformer, globalData)
  local rootNode = self:GetRootNode()
  local rootNodeID = rootNode:GetID()

  local function RecLookup(tree, nodeID, Matcher, Transformer, globalData)
    local childrenOfNode = tree:GetNodeChildren(nodeID) or {}
    local copyOfChildren = ArrayExt.ShallowCopy(childrenOfNode)
    local copyOfChildren = ArrayExt.Shuffle(copyOfChildren)
    for i=1, #copyOfChildren do
      RecLookup(tree, copyOfChildren[i], Matcher, Transformer, globalData)
    end

    if Matcher(tree, tree.nodes[nodeID], globalData) then
      Transformer(tree, tree.nodes[nodeID], globalData)
    end
  end

  RecLookup(self, rootNodeID, Matcher, Transformer, globalData)
end

function Tree:SetAParentOfB(nodeA, nodeB)
  local nodeBID = nodeB:GetID()
  local parentOfBID = self.parents[nodeBID]
  local childrenOfParentOfB = self.children[parentOfBID]

  local newChildren = {}
  for i=1, #childrenOfParentOfB do
    if childrenOfParentOfB[i] ~= nodeBID then
      newChildren[#newChildren + 1] = childrenOfParentOfB[i]
    end
  end
  self.children[parentOfBID] = newChildren

  self:AddNode(nodeB, nodeA)
end

return Tree