--[[
local nodeTypes = {
  "mapDesert",
}

local nodeTypesDefs = {}
for _, nodeTypeName  in ipairs(nodeTypes) do
  nodeTypesDefs[nodeTypeName] = require(GAME_PATH .. "data.nodeTypesDefs." .. nodeTypeName)
  nodeTypesDefs[nodeTypeName].name = nodeTypeName
end

return nodeTypesDefs
]]--

return {
  mapDesert = {
    drawDefs = {
      color = {1.0, 0.8, 0.1, 1},
    }
  },
  mapForest = {
    drawDefs = {
      color = {0.5, 0.9, 0.5, 1},
    }
  },
  mapSea = {
    drawDefs = {
      color = {0.1, 0.1, 0.9, 1},
    }
  },
}
