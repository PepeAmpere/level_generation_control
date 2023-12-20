local nodesDefs = {
  ["NorthEntrance"] = { tags = {"tc","north"}, relativePosition = Vec3(420, 0, 0) },
  ["EastEntrance"] = { tags = {"tc", "east"}, relativePosition = Vec3(0, 420, 0) },
  ["WestEntrance"] = { tags = {"tc", "west"}, relativePosition = Vec3(0, -420, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "NorthEntrance",
      "EastEntrance",
      "WestEntrance",
    },
  },
}

local drawDefs = {
    "x", "w", "x",
    "w", "w", "w",
    "x", "x", "x",
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
}