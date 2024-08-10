local entityTypes = {
  "Developer",
  "Kryssar",
  "Player",
  "Rat",
  "Team",
  "Tile",
}

local entityTypesDefs = {}
for _, entityTypeName in ipairs(entityTypes) do
  entityTypesDefs[entityTypeName] = require(GAME_PATH .. "data.entityTypesDefs." .. entityTypeName)
  entityTypesDefs[entityTypeName].name = entityTypeName
end

return entityTypesDefs