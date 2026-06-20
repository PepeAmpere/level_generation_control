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

  -- technical types
  Undefined = {
    drawDefs = {
      color = {0.1, 0.1, 0.1, 0.25},
    }
  },
  UnsupportedLegacyType = {
    drawDefs = {
      color = {0.9, 0.1, 0.1, 0.25},
    }
  },

  -- game types
  --[[
  bush_secret_trail = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  bush_local_witch_cardbox_house = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  fence_inner_trail = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  fence_outer_trail = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  grass_trail = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  house_body = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  house_entrance_cellar = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  house_entrance_front = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  house_holes = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  kostka = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  kostka_double_entrance = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  road = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  road_with_bushes = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  sand_trail = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  sandbox = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  street = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  street_with_cars = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  street_with_walkpath = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  table_mountain = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  table_mountain_secret_passage = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  trashbins_shelter = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  trashbins_shelter_roof_access = {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  water_castle_secondary_entrance= {
    drawDefs = {
      color = {0.0, 0.0, 0.0, 0.1},
    }
  },
  ]]--


  mapCity = {
    drawDefs = {
      color = {0.5, 0.5, 0.5, 1},
      icon = love.graphics.newImage(string.gsub(GAME_PATH, "%.", "/") .. "data/img/house.png"), -- ! engine specific
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
      icon = love.graphics.newImage(string.gsub(GAME_PATH, "%.", "/") .. "data/img/mountain.png"), -- ! engine specific
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