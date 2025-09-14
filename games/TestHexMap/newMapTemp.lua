local GetNodeTags = function()
  return {
    hex = true,
    hexTypeName = TableExt.GetRandomValue(HexTypesDefs).name,
    hexTreeTile = TableExt.GetRandomValue(HexTreeTilesDefs).name,
    --color = {math.random(),math.random(),math.random()}
  }
end

local rootTags = GetNodeTags()

levelMap = OneSim:AddSystem(
  "HexMap",
  {
    q = 0, r = 0, s = 0,
    rootNodeTags = rootTags,
  }
)

local SIZE = 5
local GAP_MULT = 1
local ENTITY_LIMIT = 10
HEX_SIZE = 100

for q = -GAP_MULT*SIZE, GAP_MULT*SIZE, GAP_MULT do
  for r = -GAP_MULT*SIZE, GAP_MULT*SIZE, GAP_MULT do
    for s = -GAP_MULT*SIZE, GAP_MULT*SIZE, GAP_MULT do
      if
        q + r + s == 0 and
        not (q == 0 and r == 0 and s == 0)
      then
        local hexCoords = Hex3(q, r, s, HEX_SIZE)
        local nodeID = hexCoords:ToKey()
        local nodeTags = GetNodeTags()
        levelMap.nodes[nodeID] = Node.new(
          nodeID,
          hexCoords,
          "Hex",
          nodeTags
        )

        if OneSim:GetEntityCount() < ENTITY_LIMIT then
          local x, y = hexCoords:ToPixel()
          local newEntity = OneSim:AddEntityOfType(
            EntityTypes.Person, {
              IDprefix = "person",
              position = Vec3(-y, x, 0)
            }
          )
          OneSim:AddEntityOfType(
            EntityTypes.Wagon, {
              IDprefix = "wagon",
              position = Vec3(-y, x, 0) + Vec3(math.random(-50, 50), math.random(-50, 50),0)
            }
          )
        end
      end
    end
  end
end

return levelMap