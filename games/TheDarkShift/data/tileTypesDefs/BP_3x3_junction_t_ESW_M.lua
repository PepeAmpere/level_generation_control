local nodesDefs = {
  ["EastEntrance"] = { tags = {"tc", "east"}, relativePosition = Vec3(0, 420, 0) },
  ["SouthEntrance"] = { tags = {"tc", "south"}, relativePosition = Vec3(-420, 0, 0) },
  ["WestEntrance"] = { tags = {"tc", "west"}, relativePosition = Vec3(0, -420, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "EastEntrance",
      "SouthEntrance",
      "WestEntrance",
    },
  },
}

local drawDefs = {
  "x", "x", "x",
  "w", "w", "w",
  "x", "w", "x",
}

local restrictions = {
  north = 0,
  east = 2,
  south = 2,
  west = 2,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}