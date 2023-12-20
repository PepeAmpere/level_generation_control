local tileTypes = {
  "BP_3x3_base_crossroad",
  "BP_3x3_exit_door_R_E_M",
  "BP_3x3_kitchen",
  "BP_3x3_ritual_room",

  -- ends
  "BP_3x3_end_W_M",
  "BP_3x3_end_N_M",
  "BP_3x3_end_E_M",
  "BP_3x3_end_S_M",
  
  -- corners
  "BP_3x3_turn_SW_M",
  "BP_3x3_turn_NW_M",
  "BP_3x3_turn_NE_M",
  "BP_3x3_turn_ES_M",

  -- junctions without doors
  "BP_3x3_junction_t_NES_M",
  "BP_3x3_junction_t_ESW_M",
  "BP_3x3_junction_t_NSW_M",
  "BP_3x3_junction_t_NEW_M",

  -- simple corridors
  "BP_3x3_corridor_horizontal_M",
  "BP_3x3_corridor_vertical_M",

  "Undefined",
}

local tileTypesDefs = {}
for i, tileTypeName in ipairs(tileTypes) do
  tileTypesDefs[tileTypeName] = require("data.tileTypesDefs." .. tileTypeName)
  tileTypesDefs[tileTypeName].name = tileTypeName
end

return tileTypesDefs

-- NEW TILE TEMPLATE

--[[
-- default nodes connecting with neighbor tiles

-- TAGS
-- tc = tiles connector
-- is = item placement spot
-- sp = start position
-- exit = end game spot

local nodesData = {
  ["NorthEntrance"] = { relativePosition = Vec3(400, 0, 0) },
  ["EastEntrance"] = { relativePosition = Vec3(0, 400, 0) },
  ["SouthEntrance"] = { relativePosition = Vec3(-400, 0, 0) },
  ["WestEntrance"] = { relativePosition = Vec3(0, -400, 0) },
}

-- trivial connection of all nodes to each other via one multiedge

-- TAGS
-- pp = physical proximity
-- sp = structural proximity

-- TYPES
-- directional - simple edge type going from node to another in defined direction
-- multiedge - edge type connecting 2+ nodes in both directions

local edgesData = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "NorthEntrance",
      "EastEntrance",
      "SouthEntrance",
      "WestEntrance",
    },
  },
}

-- data defining the color classes
-- colors mapping: in Colors.lua

local drawData = {
    "x", "w", "x",
    "w", "w", "w",
    "x", "w", "x",
}

return {
  nodesData = nodesData,
  edgesData = edgesData,
  drawData = drawData,
} 

]]--