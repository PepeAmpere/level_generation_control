local nodesDefs = {
  ["NorthEntrance"] = { tags = {"tc", "north"}, relativePosition = Vec3(420, 0, 0) },
  ["EastEntrance"] = { tags = {"tc", "east"}, relativePosition = Vec3(0, 420, 0) },
  ["Corner"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "NorthEntrance",
      "EastEntrance",
      "Corner",
    },
  },
}

local drawDefs = {
    "x", "w", "x",
    "x", "w", "w",
    "x", "x", "x",
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
}