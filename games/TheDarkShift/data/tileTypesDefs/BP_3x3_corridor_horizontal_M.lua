local nodesDefs = {
  ["EastEntrance"] = { tags = {"tc", "east"}, relativePosition = Vec3(0, 420, 0) },
  ["WestEntrance"] = { tags = {"tc", "west"}, relativePosition = Vec3(0, -420, 0) },
  ["Middle"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "NorthEntrance",
      "Middle",
      "WestEntrance",
    },
  },
}

local drawDefs = {
  "x", "x", "x",
  "w", "w", "w",
  "x", "x", "x",
}

local restrictions = {
  north = 0,
  east = 2,
  south = 0,
  west = 2,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}