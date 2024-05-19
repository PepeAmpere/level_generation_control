local forumula = "W(MUB,TZ)F(ME,TUB)RF(ME,TVB)"

local function Matcher(constructorTree, tile, levelMap)
  local parentTile = constructorTree:GetParentOf(tile)
  if
    parentTile and
    parentTile:GetDirectionOf(tile) --fixme
  then
    local newTurtle = TTE.new(
      tile:GetPosition(),
      parentTile:GetDirectionOf(tile),
      levelMap.tileSize,
      forumula
    )
    local matchResult = newTurtle:Match(levelMap)
    return matchResult
  end
  return false
end

local function Transformer(constructorTree, tile, levelMap)
  local parentTile = constructorTree:GetParentOf(tile)
  if
    parentTile and
    parentTile:GetDirectionOf(tile) --fixme
  then
    local newTurtle = TTE.new(
      tile:GetPosition(),
      parentTile:GetDirectionOf(tile),
      levelMap.tileSize,
      forumula
    )
    return newTurtle:Transform(levelMap, tile)
  end
  return false
end

return {
  Matcher = Matcher,
  Transformer = Transformer,
}