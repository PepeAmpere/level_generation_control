-- constants & functions localization
local DIRECTIONS = MapExt.DIRECTIONS

local productionFormulas = {
  "W(MVY,TUY)F(ME,TVY)",
}

local function SearchAndTransform(Matcher, Transformer, levelMap)
  local constructorTree = levelMap:GetConstructorTree()
  local _, deepestTile = constructorTree:GetMaxDepth()
  local parentTile = constructorTree:GetParentOf(deepestTile)
  local parentDirection = parentTile:GetDirectionOf(deepestTile)
  local formula = ArrayExt.Shuffle(productionFormulas)[1]
  local directionsCopy = ArrayExt.ShallowCopy(DIRECTIONS)
  local directionsCopy = ArrayExt.Shuffle(directionsCopy)

  for _, direction in ipairs(directionsCopy) do
    if Matcher(constructorTree, deepestTile, levelMap, direction, formula) then
      Transformer(constructorTree, deepestTile, levelMap, direction, formula)
      break
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