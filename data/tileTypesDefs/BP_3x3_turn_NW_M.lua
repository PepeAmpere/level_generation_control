local nodesDefs = {
  ["NorthEntrance"] = { tags = {"tc", "north"}, relativePosition = Vec3(420, 0, 0) },
  ["WestEntrance"] = { tags = {"tc", "west"}, relativePosition = Vec3(0, -420, 0) },
  ["Corner"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "NorthEntrance",
      "Corner",
      "WestEntrance",
    },
  },
}

local drawDefs = {
    "x", "w", "x",
    "w", "w", "x",
    "x", "x", "x",
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
}