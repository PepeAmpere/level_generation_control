local function LayoutBasedGenerator(layoutSteps)

  -- rules of spawning
  local tileSize = MapExt.TILE_SIZE

  -- functions localization
  local GetMapTileKey = MapExt.GetMapTileKey

  -- global for easier Unreal debugging
  -- make map
  local levelMap = Map.new(Vec3(-1800, -1800, 0), tileSize)

  local ruleNames = productionRulesTypes
  local ruleDefs = productionRulesDefs

  local newScores = {
    iterations = 0,
    filteredNames = {},
  }
  levelMap:ConstructionUpdateScores(newScores)

  local step = 1
  for i=1, 50 do
    -- testing update only
    levelMap:ConstructionUpdateScores({iterations = i})

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
        " production rule e.g.: ", productionRulesNames[1]
      )
      -- APPLY ALL APPLICABLE RULES
      for _, ruleName in ipairs(productionRulesNames) do
        local ruleDef = ruleDefs[ruleName]
        local constructionTree = levelMap:GetConstructorTree()
        levelMap:ConstructionIncrementRuleMatchCounter(ruleName)

        if ruleDef.SearchAndTransform then
          -- this rule has special combo of search, match and transformation
          ruleDef.SearchAndTransform(
            ruleDef.Matcher,
            ruleDef.Transformer,
            levelMap
          )
        else
          -- this rule is using more simple match & transform on spot rules
          -- DFS-execution order + non-leaf nodes executed on return path
          constructionTree:RunSearchAndTransform(
            ruleDef.Matcher,
            ruleDef.Transformer,
            levelMap
          )
        end
      end
    end
  end

  levelMap:ConstructionDebugCounters()

  return levelMap
end

return LayoutBasedGenerator