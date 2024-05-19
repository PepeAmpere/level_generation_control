local layoutTypes = {
  "BlockedPath",
  "FirstEscape",
  "FirstKey",
  "FullHouse",
}

local layoutTypesDefs = {}
for _, layoutTypeName in ipairs(layoutTypes) do
  layoutTypesDefs[layoutTypeName] = require(GAME_PATH .. "data.layoutTypesDefs." .. layoutTypeName)
end

return {layoutTypes, layoutTypesDefs}