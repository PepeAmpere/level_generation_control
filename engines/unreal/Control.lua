-- we try to keep this empty for unreal current integrations
-- Lua objects/tables/simulation is accessed directly, without intermediate layer

-- only functions contained here are typically those used from Unreal lua files realted to the init phase

-- localization of Unreal functions
local UCreateEntity = UnrealControlCreateEntity
local USetParentEntity = UnrealControlSetParentEntity

local UnrealControl = {}

UnrealControl.CreateAllActors = function()
  local allEntities = OneSim:GetEntities()
  for entityID, entity in pairs(allEntities) do
    local posComponent = entity:GetComponent("Position")
    local entityTypeName = entity:GetTypeName()
    -- print(entityTypeName)
    if
      posComponent and
      entityTypeName ~= "Player" and
      entityTypeName ~= "Tile" and
      entityTypeName ~= "Team"
    then
      UCreateEntity(
        EntityTypes[entityTypeName].blueprint,
        posComponent:Get() + 
          Vec3(110 - math.random(60),0,0) +
          EntityTypes[entityTypeName].offsetCorrection,
        entityID
      )
    end
  end

  return allEntities
end

UnrealControl.CreateAllTeams = function()
  local allEntities = OneSim:GetEntities()
  for entityID, entity in pairs(allEntities) do
    local entityTypeName = entity:GetTypeName()
    if entityTypeName == "Team" then
      UCreateEntity(
        EntityTypes[entityTypeName].blueprint,
        Vec3(0,0,0),
        entityID
      )
    end
  end
end

UnrealControl.CreateAllTiles = function()
  local allEntities = OneSim:GetEntities()
  for entityID, entity in pairs(allEntities) do
    local posComponent = entity:GetComponent("Position")
    local entityTypeName = entity:GetTypeName()
    if posComponent and entityTypeName == "Tile" then
      UCreateEntity(
        EntityTypes[entityTypeName].blueprint,
        posComponent:Get(),
        entityID
      )
    end
  end
end

return UnrealControl
