local nodesDefs = {
  ["NorthEntrance"] = { tags = {"tc","north"}, relativePosition = Vec3(420, 0, 0) },
  ["EastEntrance"] = { tags = {"tc", "east"}, relativePosition = Vec3(0, 420, 0) },
  ["SouthEntrance"] = { tags = {"tc", "south"}, relativePosition = Vec3(-420, 0, 0) },
  ["WestEntrance"] = { tags = {"tc", "west"}, relativePosition = Vec3(0, -420, 0) },
}

local edgesDefs = {
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

local drawDefs = {
  "w", "w", "w",
  "w", "w", "w",
  "w", "w", "w",
}

local restrictions = {
  north = 1,
  east = 1,
  south = 1,
  west = 1,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}