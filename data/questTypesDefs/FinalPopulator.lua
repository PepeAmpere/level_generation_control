local ValuesToArray = TableExt.ValuesToArray

local builders = {
  [1] = function(q, levelMap)
    local undefinedTilesTable = levelMap:GetUndefinedTiles()
    local undefinedTilesArray = ValuesToArray(undefinedTilesTable) -- new instance of table
    local shuffledTiles = ArrayExt.Shuffle(undefinedTilesArray)

   for i=1, #shuffledTiles do
      local tile = shuffledTiles[i]

      -- tileTypesDefs is the table
      local tileTypesArray = ValuesToArray(tileTypesDefs) -- new instance of table
      local shuffledTileTypes = ArrayExt.Shuffle(tileTypesArray)

      for j=1, #shuffledTileTypes do
        local selectedTileType = shuffledTileTypes[j]

        if tile:IsMatchingTransformation(selectedTileType) then
          levelMap:TransformTileToType(tile, selectedTileType)
          break
        end
      end
    end
  end,
}

return {
  builders = builders
}