local productionFormula = "W(MHE,TZ)W(MU,TRE)F(MVY,TZ)"

return {
  Example = {
    Matcher = function (constructorTree, node, levelMap)
      local tilesCounts = levelMap:ConstructionGetTilesCountPerType()

      -- condition
      local notGeneratedYet = tilesCounts["mapDesert"] < 10

      if notGeneratedYet then
        local newTurtle = TTE.new(
          node:GetPosition(),
          "east", -- explicitly!
          levelMap.tileSize,
          productionFormula
        )
        local matchResult = newTurtle:Match(levelMap)
        return matchResult
      end
      return false
    end,

    Transformer = function(constructorTree, tile, levelMap)
      local newTurtle = TTE.new(
        tile:GetPosition(),
        "east", -- explicitly!
        levelMap.tileSize,
        productionFormula
      )
      return newTurtle:Transform(levelMap, tile)
    end,
  }
}