local globalConditions = {
  -- just the initial tile setup
  function(levelMap)
    local tilesCounts = levelMap:ConstructionGetTilesCoutPerType()

    -- condition
    local result = tilesCounts["BP_3x3_exit_door_R_E_M"] >= 1

    -- list of applicable rules if condition is not met
    local productionRulesNames = {
      "InitialExit",
    }

    return result, productionRulesNames
  end,

  -- get closer to the anticipated blue part
  -- keep few grow opportunities along the lines
  -- but go agresivelly towards to wanted position, no breadth if possible
  function(levelMap)
    local constructorScores = levelMap:ConstructionGetScoresCopy()
    local tilesCounts = levelMap:ConstructionGetTilesCoutPerType()

    -- condition
    local result = tilesCounts["Undefined_yellow"] > 8

    -- list of applicable rules if condition is not met
    productionRulesNames = {
      "YellowLeafLongCustomCorridor",
    }

    return result, productionRulesNames
  end,

  -- add ritual room to any reasonable tile
  function(levelMap)
    local constructorScores = levelMap:ConstructionGetScoresCopy()
    local tilesCounts = levelMap:ConstructionGetTilesCoutPerType()

    -- condition
    local result = tilesCounts["BP_3x3_ritual_room"] >= 1

    -- list of applicable rules if condition is not met
    local productionRulesNames = {
      "YellowToBlue",
    }

    return result, productionRulesNames
  end,

  -- grow blue part and maybe make some rooms as part of it
  function(levelMap)
    local constructorScores = levelMap:ConstructionGetScoresCopy()
    local tilesCounts = levelMap:ConstructionGetTilesCoutPerType()

    -- condition
    local result = tilesCounts["Undefined_blue"] >= 15

    -- list of applicable rules if condition is not met
    local productionRulesNames = {
      "BlueExtendAroundCorridor",
    }

    return result, productionRulesNames
  end,

  -- grow blue part and maybe make some rooms as part of it
  function(levelMap)
    local constructorScores = levelMap:ConstructionGetScoresCopy()
    local tilesCounts = levelMap:ConstructionGetTilesCoutPerType()

    -- condition
    local result = tilesCounts["Undefined_blue"] >= 25

    -- list of applicable rules if condition is not met
    local productionRulesNames = {
      "BlueExtend",
    }

    return result, productionRulesNames
  end,
}

local function QuestBasedGenerator()

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
  for i=1, 100 do
    -- testing update only
    levelMap:ConstructionUpdateScores({iterations = i})

    -- CHECK GLOBAL END CONDITION
    -- 1) no other steps?
    if step > #globalConditions then break end
    local currentConditionResult, productionRulesNames = globalConditions[step](levelMap)

    if currentConditionResult then
      step = step + 1
    else

      print("iteration ", i, " using rules of step ", step)
      -- APPLY ALL APPLICABLE RULES
      for _, ruleName in ipairs(productionRulesNames) do
        local ruleDef = ruleDefs[ruleName]
        local constructionTree = levelMap:GetConstructorTree()
        levelMap:ConstructionIncrementMatchCounter(ruleName)

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

  return levelMap
end

return QuestBasedGenerator