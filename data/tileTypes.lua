local tileTypes = {
  "BP_3x3_base_crossroad",

  -- rooms
  "BP_3x3_exit_door_R_E_M",
  "BP_3x3_kitchen",
  "BP_3x3_ritual_room",
  "BP_3x3_ritual_room_Loop0",
  "BP_3x3_office",
  "BP_3x3_restroom_female",
  "BP_3x3_restroom_male",
  "BP_3x3_restroom_male_alt",
  "BP_3x3_candleRoom",

  -- special rooms
  "BP_3x3_diner_entrance",
  "BP_3x3_diner_table_area",

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
  "BP_3x3_corridor_horizontal_M_boxes",

  -- variables for generation
  "Undefined",
  "Virtual",
}

local variables = {
  "BP_3x3_exit_door_R_E_M",
  "BP_3x3_kitchen",
  "BP_3x3_ritual_room",
  "BP_3x3_office",
  "BP_3x3_restroom_female",
  "BP_3x3_restroom_male",
}

local tileTypesDefs = {}
for _, tileTypeName in ipairs(tileTypes) do
  tileTypesDefs[tileTypeName] = require("data.tileTypesDefs." .. tileTypeName)
  tileTypesDefs[tileTypeName].name = tileTypeName
end

for _, variableName in ipairs(variables) do
  local fullName = variableName .. "_variable"
  tileTypesDefs[fullName] = TableExt.ShallowCopy(tileTypesDefs[variableName])
  tileTypesDefs[fullName].name = fullName
end

return tileTypesDefs

-- NEW TILE TEMPLATE

--[[
-- NODE TAGS
-- tc = tiles connector
-- is = item placement spot
-- sp = start position
-- exit = end game spot

-- default nodes connecting with neighbor tiles
local nodesData = {
  ["NorthEntrance"] = { relativePosition = Vec3(400, 0, 0) },
  ["EastEntrance"] = { relativePosition = Vec3(0, 400, 0) },
  ["SouthEntrance"] = { relativePosition = Vec3(-400, 0, 0) },
  ["WestEntrance"] = { relativePosition = Vec3(0, -400, 0) },
}

-- EDGE TAGS
-- pp = physical proximity
-- sp = structural proximity
-- d = door
-- k_<N> = key of number N is needed to unlock given doors, e.g. k_198751
-- k_<c> = key of color c is needed to unlock given doors, e.g. k_red

-- TYPES
-- directional - simple edge type going from node to another in defined direction
-- multiedge - edge type connecting 2+ nodes in both directions

-- trivial connection of all nodes to each other via one multiedge
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

local drawDefs = {
  "w", "x", "x",
  "x", "w", "w",
  "w", "x", "x",
}

-- restrictions
-- 0 -- must not passable
-- 1 -- undefined
-- 2 -- must passable

local restrictions = {
  north = 0,
  east = 2,
  south = 0,
  west = 0,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}

]]
   --
