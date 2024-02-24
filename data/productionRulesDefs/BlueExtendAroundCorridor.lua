-- constants & functions localization
local DIRECTIONS = MapExt.DIRECTIONS

local productionFormulas = {
  "W(MVB,TUB)F(ME,TUB)LF(ME,TVB)",
  "W(MVB,TUB)F(ME,TUB)RF(ME,TUB)LF(ME,TUB)LF(ME,TUB)F(ME,TVB)",
  "W(MUB,TZ)F(ME,TUB)RF(ME,TVB)",
  "W(MHN,TZ)W(MUB,TZ)F(ME,TRRM)",
  "W(MHS,TZ)W(MUB,TZ)F(ME,TRDE)LF(ME,TRDT)RFRFFRF",
}

local function SearchAndTransform(Matcher, Transformer, levelMap)
  local constructorTree = levelMap:GetConstructorTree()
  local _, deepestTile = constructorTree:GetMaxDepth()
  local formula = ArrayExt.Shuffle(productionFormulas)[1]
  local randomDirection = ArrayExt.Shuffle(ArrayExt.ShallowCopy(DIRECTIONS))[1]

  if Matcher(constructorTree, deepestTile, levelMap, randomDirection, formula) then
    Transformer(constructorTree, deepestTile, levelMap, randomDirection, formula)
  else
    for _, direction in ipairs(DIRECTIONS) do
      if Matcher(constructorTree, deepestTile, levelMap, direction, formula) then
        Transformer(constructorTree, deepestTile, levelMap, direction, formula)
        break
      end
    end
  end
end

local function Matcher(constructorTree, tile, levelMap, direction, forumula)
  local newTurtle = TTE.new(
    tile:GetPosition(),
    direction,
    levelMap.tileSize,
    forumula
  )
  local matchResult = newTurtle:Match(levelMap)
  return matchResult
end

local function Transformer(constructorTree, tile, levelMap, direction, formula)
  local newTurtle = TTE.new(
    tile:GetPosition(),
    direction,
    levelMap.tileSize,
    formula
  )
  return newTurtle:Transform(levelMap, tile)
end

return {
  SearchAndTransform = SearchAndTransform,
  Matcher = Matcher,
  Transformer = Transformer,
}