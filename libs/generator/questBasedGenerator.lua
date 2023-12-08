-- rules of spawning
local minX = -4
local minY = -4
local maxX = 4
local maxY = 4
local tileSiZe = 900

-- functions localization
local GetMapTileKey = MapExt.GetMapTileKey

-- global for easier Unreal debugging
-- make map
levelMap = Map.new(minX, maxX, minY, maxY, tileSiZe)

-- covert first tile
local startTile = levelMap:GetTile(GetMapTileKey(Vec3(0,0,0)))
levelMap:TransformTileToType(startTile, tileTypesDefs["RitualRoom"])

-- experimental conversion
local randomCrossTile = levelMap:GetTile(
  GetMapTileKey(
    Vec3(
      math.random(2,3)*900,
      math.random(2,3)*900,
      0
    )
  )
)
levelMap:TransformTileToType(randomCrossTile, tileTypesDefs["Crossroad"])

return levelMap