-- constants & functions localization
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE

local productionFormula = "W(MVY,TUY)F(ME,TUY)LF(ME,TUY)RF(ME,TVY)"
--local productionFormula = "W(MVY,TUY)F(ME,TUY)L(MA,TZ)F(ME,TUY)R(MA,TZ)F(ME,TVY)"

local function Matcher(constructionTree, tile, levelMap)
  local parentTile = constructionTree:GetParentOf(tile)
  if
    parentTile and
    parentTile:GetDirectionOf(tile) --fixme
  then
    local newTurtle = TTE.new(
      tile:GetPosition(),
      parentTile:GetDirectionOf(tile),
      levelMap.tileSize,
      productionFormula
    )
    local matchResult = newTurtle:Match(levelMap)
    return matchResult
    end
  return false
end

local function Transformer(constructionTree, tile, levelMap)
  local parentTile = constructionTree:GetParentOf(tile)

  local newTurtle = TTE.new(
    tile:GetPosition(),
    parentTile:GetDirectionOf(tile),
    levelMap.tileSize,
    productionFormula
  )
  return newTurtle:Transform(levelMap, tile)
end

return {
  Matcher = Matcher,
  Transformer = Transformer,
}