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

local hexTypesDefs = {
  mapCity = {
    drawDefs = {
      color = {0.5, 0.5, 0.5, 1},
      icon = love.graphics.newImage(string.gsub(GAME_PATH, "%.", "/") .. "data/img/house.png"),
    }
  },
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
      icon = love.graphics.newImage(string.gsub(GAME_PATH, "%.", "/") .. "data/img/tree.png"), -- ! engine specific
    }
  },
  mapMountains = {
    drawDefs = {
      color = {0.7, 0.5, 0.6, 1},
      icon = love.graphics.newImage(string.gsub(GAME_PATH, "%.", "/") .. "data/img/mountain.png"),
    }
  },
  mapSea = {
    drawDefs = {
      color = {0.1, 0.1, 0.9, 1},
    }
  },
}

local hexTypesArray = {}
for hexType, _ in pairs(hexTypesDefs) do
  local newDefID = #hexTypesArray+1
  hexTypesDefs[hexType].name = hexType
  hexTypesDefs[hexType].defID = newDefID
  hexTypesArray[#hexTypesArray+1] = hexTypesDefs[hexType]
end

for i,v in ipairs(hexTypesArray) do hexTypesDefs[i] = v end

return hexTypesDefs