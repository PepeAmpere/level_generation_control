return {

-- just the initial tile setup
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

-- get closer to the anticipated blue part
-- keep few grow opportunities along the lines
-- but go agresivelly towards to wanted position, no breadth if possible
function(levelMap)
  local constructorScores = levelMap:ConstructionGetScoresCopy()
  local count = levelMap:ConstructionGetTilesCountPerTurtleMatch("W(MAY,TZ)")

  -- condition
  local result = count > 3

  -- list of applicable rules if condition is not met
  productionRulesNames = {
    "YellowLeafLongCustomCorridor",
  }

  return result, productionRulesNames
end,

-- add ritual room to any reasonable tile
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