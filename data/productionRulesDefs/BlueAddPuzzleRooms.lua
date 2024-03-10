local productionFormula = "W(MHE,TZ)W(MUB,TZ)F(ME,TRK)P(BP,BP)LF(ME,TCES)Q(BP,BP)RF(ME,TCEN)"

local function Matcher(constructorTree, tile, levelMap)

  -- condition
  local notGeneratedYet = levelMap:ConstructionGetFormulaCount(productionFormula) < 1

  if notGeneratedYet then
    local newTurtle = TTE.new(
      tile:GetPosition(),
      "east", -- explicitly!
      levelMap.tileSize,
      productionFormula
    )
    local matchResult = newTurtle:Match(levelMap)
    return matchResult
  end
  return false
end

local function Transformer(constructorTree, tile, levelMap)
  local newTurtle = TTE.new(
    tile:GetPosition(),
    "east", -- explicitly!
    levelMap.tileSize,
    productionFormula
  )
  return newTurtle:Transform(levelMap, tile)
end

return {
  Matcher = Matcher,
  Transformer = Transformer,
}