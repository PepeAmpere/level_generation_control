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

local hexTypes = {
  mapDesert = {
    drawDefs = {
      color = {1.0, 0.8, 0.1, 1},
    }
  },
  mapField = {
    drawDefs = {
      color = {0.5, 0.9, 0.2, 1},
    }
  },
  mapForest = {
    drawDefs = {
      color = {0.01, 0.6, 0.25, 1},
    }
  },
  mapSea = {
    drawDefs = {
      color = {0.1, 0.1, 0.9, 1},
    }
  },
}

for hexType, _ in pairs(hexTypes) do
  hexTypes[hexType].name = hexType
end

return hexTypes