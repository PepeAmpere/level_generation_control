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

  -- very short yellow corridor
  function(levelMap)
    local constructorScores = levelMap:ConstructionGetScoresCopy()
    local count = levelMap:ConstructionGetTilesCountPerTurtleMatch("W(MAY,TZ)")

    -- condition
    local result = count > 1

    -- list of applicable rules if condition is not met
    productionRulesNames = {
      "YellowShort",
    }

    return result, productionRulesNames
  end,

  -- add ritual room to any reasonable tile
  function(levelMap)
    local constructorScores = levelMap:ConstructionGetScoresCopy()
    local tilesCounts = levelMap:ConstructionGetTilesCountPerType()

    -- condition
    local result = tilesCounts["BP_3x3_ritual_room_Loop0"] >= 1

    -- list of applicable rules if condition is not met
    local productionRulesNames = {
      "RitualRoomLoopZero",
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
