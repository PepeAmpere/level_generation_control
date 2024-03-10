local productionFormulas = {
  "W(MUV,TCG)"
}
local DIRECTIONS = MapExt.DIRECTIONS

local function SearchAndTransform(Matcher, Transformer, levelMap)
  local constructorTree = levelMap:GetConstructorTree()
  local formula = ArrayExt.Shuffle(productionFormulas)[1]
  local nodes = constructorTree:GetNodes()

  for nodeID, node in pairs(nodes) do
    local parentTile = constructorTree:GetParentOfID(nodeID)
    if parentTile then
      local parentDirection = parentTile:GetDirectionOf(node)
      if Matcher(constructorTree, node, levelMap, parentDirection, formula) then
        Transformer(constructorTree, node, levelMap, parentDirection, formula)
      end
    end
  end
end

local function Matcher(constructorTree, tile, levelMap, direction, formula)
  local newTurtle = TTE.new(
    tile:GetPosition(),
    direction,
    levelMap.tileSize,
    formula
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