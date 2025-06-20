-- dependency on generic
-- * ArrayExt
-- * Edge
-- * Node
-- * Graph
-- and depedendy on hex specific
-- * Hex3
-- which is loaded externally to reduce environment specific code

local HexMap = {}
HexMap.__index = HexMap
setmetatable(HexMap, Graph)

function HexMap.new(q, r, s, rootNodeTags)
  local i = setmetatable({}, HexMap) -- make new instance

  i.nodes = {}

  local rootPosition = Hex3(q,r,s)
  local rootNodeID = rootPosition:ToKey()
  local rootNodesTagsCopy = TableExt.ShallowCopy(rootNodeTags)
  local rootNode = Node.new(
    rootNodeID,
    rootPosition,
    "Hex",
    rootNodesTagsCopy
  )
  i.nodes[rootNodeID] = rootNode

  i.constructorTree = Tree.new(rootNode)
  i.constructorScores = {
    rules = {},
    forumulas = {},
    transformers = {},
  }
  i.edges = {}
  i.paths = {}

  return i
end

function HexMap:ContructByLayout(layoutSteps, ruleDefs)
  local newScores = {
    iterations = 0,
    filteredNames = {},
  }
  self:ConstructionUpdateScores(newScores)

  local step = 1
  for i = 1, 50 do
    -- testing update only
    self:ConstructionUpdateScores({ iterations = i })

    -- CHECK GLOBAL END CONDITION
    -- 1) no other steps?
    if step > #layoutSteps then break end
    local currentConditionResult, productionRulesNames = layoutSteps[step](levelMap)

    if currentConditionResult then
      step = step + 1
    else
      print(
        "iteration ", i,
        " using rules of step ", step,
        " production rule e.g.: "
      )
      -- APPLY ALL APPLICABLE RULES
      for _, ruleName in ipairs(productionRulesNames) do
        local ruleDef = ruleDefs[ruleName]
        local constructionTree = levelMap:GetConstructorTree()
        self:ConstructionIncrementRuleMatchCounter(ruleName)

        if ruleDef.SearchAndTransform then
          -- this rule has special combo of search, match and transformation
          ruleDef.SearchAndTransform(
            ruleDef.Matcher,
            ruleDef.Transformer,
            self
          )
        else
          -- this rule is using more simple match & transform on spot rules
          -- DFS-execution order + non-leaf nodes executed on return path
          constructionTree:RunSearchAndTransform(
            ruleDef.Matcher,
            ruleDef.Transformer,
            self
          )
        end
      end
    end
  end

  self:ConstructionDebugCounters()
end

function HexMap:ConstructionDebugCounters()
  local function PrintCounters(counter)
    for rule, count in pairs(counter) do
      print(rule .. ": " .. count)
    end
  end

  PrintCounters(self.constructorScores.rules)
  PrintCounters(self.constructorScores.transformers)
  PrintCounters(self.constructorScores.forumulas)
end

function HexMap:ConstructionGetFormulaCount(formulaName)
  return self.constructorScores.forumulas[formulaName] or 0
end

function HexMap:ConstructionGetRuleCount(ruleName)
  return self.constructorScores.rules[ruleName] or 0
end

function HexMap:ConstructionGetTransformerCount(transformerName)
  return self.constructorScores.transformers[transformerName] or 0
end

function HexMap:ConstructionGetMaxDepth()
  local constructorTree = self:GetConstructorTree()
  return constructorTree:GetMaxDepth()
end

function HexMap:ConstructionGetParentTileDirection(tile)
  local constructorTree = self:GetConstructorTree()
  local rootNode = constructorTree:GetRootNode()
  if not rootNode:IsEqual(tile) then
    local parentTile = constructorTree:GetParentOf(tile)
    return parentTile:GetDirectionOf(tile)
  end
end

function HexMap:ConstructionGetScoresCopy()
  local scores = {}
  for k,v in pairs(self.constructorScores) do
    scores[k] = v
  end
  return scores
end

function HexMap:ConstructionIncrementFormulaMatchCounter(formulaName)
  local currentCounter = self.constructorScores.forumulas[formulaName]
  self.constructorScores.forumulas[formulaName] = (currentCounter or 0) + 1
end

function HexMap:ConstructionIncrementRuleMatchCounter(ruleName)
  local currentCounter = self.constructorScores.rules[ruleName]
  self.constructorScores.rules[ruleName] = (currentCounter or 0) + 1
end

function HexMap:ConstructionIncrementTransformerCounter(transformerName)
  local currentCounter = self.constructorScores.transformers[transformerName]
  self.constructorScores.transformers[transformerName] = (currentCounter or 0) + 1
end

function HexMap:ConstructionUpdateScoreByRule(ruleFn)
  self = ruleFn(self)
end

function HexMap:ConstructionUpdateScores(newScores)
  for k,v in pairs(newScores) do
      self.constructorScores[k] = v
  end
end

function HexMap:GetConstructorTree()
  return self.constructorTree
end

return HexMap