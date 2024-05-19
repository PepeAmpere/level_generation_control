local productionFormula = "W(MHN,TZ)W(MUB,TZ)F(ME,TRC)"

local function Matcher(constructorTree, tile, levelMap)

  -- condition
  local notGeneratedYet = levelMap:ConstructionGetFormulaCount(productionFormula) < 1

  if notGeneratedYet then
    local newTurtle = TTE.new(
      tile:GetPosition(),
      "north", -- explicitly!
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
    "north", -- explicitly!
    levelMap.tileSize,
    productionFormula
  )
  return newTurtle:Transform(levelMap, tile)
end

return {
  Matcher = Matcher,
  Transformer = Transformer,
}