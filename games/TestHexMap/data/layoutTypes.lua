return {
  FirstLevel = {

    -- STEP
    function(levelMap)
      local tilesCounts = levelMap:ConstructionGetTilesCountPerType()

      -- condition
      local result = tilesCounts["BP_3x3_exit_door_R_E_M"] >= 1

      -- list of applicable rules if condition is not met
      local productionRulesNames = {
        "Example",
      }

      return result, productionRulesNames
    end,
  }
}
