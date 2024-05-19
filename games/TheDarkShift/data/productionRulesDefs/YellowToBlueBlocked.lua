local productionFormula = "W(MAY,TZ)W(MHN,TUY)F(ME,TRRB)RF(ME,TVB)RFLFLFFLF"

local function Matcher(constructorTree, tile, levelMap)
  local tilesCounts = levelMap:ConstructionGetTilesCountPerType()

  -- condition
  local notGeneratedYet = tilesCounts["BP_3x3_ritual_room"] < 1

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