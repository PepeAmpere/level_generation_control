local nodesDefs = {
  ["NorthEntrance"] = { tags = {"tc"}, relativePosition = Vec3(400, 0, 0) },
  ["EastEntrance"] = { tags = {"tc"}, relativePosition = Vec3(0, 400, 0) },
  ["SouthEntrance"] = { tags = {"tc"}, relativePosition = Vec3(-400, 0, 0) },
  ["WestEntrance"] = { tags = {"tc"}, relativePosition = Vec3(0, -400, 0) },
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

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
}