local nodesDefs = {
  ["SouthEntrance"] = { tags = {"tc", "south"}, relativePosition = Vec3(-420, 0, 0) },
  ["WestEntrance"] = { tags = {"tc", "west"}, relativePosition = Vec3(0, -420, 0) },
  ["Corner"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "WestEntrance",
      "Corner",
      "SouthEntrance",
    },
  },
}

local drawDefs = {
    "x", "x", "x",
    "w", "w", "x",
    "x", "w", "x",
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
}