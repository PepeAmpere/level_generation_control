return {

-- make exit room
function(levelMap)
  local tilesCounts = levelMap:ConstructionGetTilesCountPerType()

  -- condition
  local result = tilesCounts["BP_3x3_exit_door_R_E_M"] >= 1

  -- list of applicable rules if condition is not met
  local productionRulesNames = {
    "InitialExit",
  }

  return result, productionRulesNames
end,

-- make short yellow corridor
function(levelMap)
  local constructorScores = levelMap:ConstructionGetScoresCopy()
  local count = levelMap:ConstructionGetTilesCountPerTurtleMatch("W(MAY,TZ)")

  -- condition
  local result = count > 4

  -- list of applicable rules if condition is not met
  productionRulesNames = {
    "YellowLeafLongCustomCorridor",
  }

  return result, productionRulesNames
end,

-- make ritual room
function(levelMap)
  local constructorScores = levelMap:ConstructionGetScoresCopy()
  local tilesCounts = levelMap:ConstructionGetTilesCountPerType()

  -- condition
  local result = tilesCounts["BP_3x3_ritual_room"] >= 1

  -- list of applicable rules if condition is not met
  local productionRulesNames = {
    "YellowToBlue",
  }

  return result, productionRulesNames
end,

-- make short blue corridor
function(levelMap)
  local constructorScores = levelMap:ConstructionGetScoresCopy()
    local count = levelMap:ConstructionGetTilesCountPerTurtleMatch("W(MUB,TZ)")

  -- condition
  local result = count >= 4

  -- list of applicable rules if condition is not met
  local productionRulesNames = {
    "BlueExtendAroundCorridor",
  }

  return result, productionRulesNames
end,

-- make candle room
function(levelMap)
  -- condition
  local formula = "W(MHN,TZ)W(MUB,TZ)F(ME,TRC)"
  local result = levelMap:ConstructionGetFormulaCount(formula) >= 1

  -- list of applicable rules if condition is not met
  local productionRulesNames = {
    "BlueCandleRoom",
  }

  return result, productionRulesNames
end,

-- convert all Undefined_yellow and Undefined_blue to actual corridor tiles
function(levelMap)
  local tilesCounts = levelMap:ConstructionGetTilesCountPerType()

  -- condition
  local result = (tilesCounts["Undefined"] == 0)

  -- list of applicable rules if condition is not met
  local productionRulesNames = {
    "UndefinedToCorridors",
  }

  return result, productionRulesNames
end,
}