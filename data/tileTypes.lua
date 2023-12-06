local tileTypes = {
  "Crossroad",
  "ExitDoor",
  "Undefined",
  "RitualRoom",
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