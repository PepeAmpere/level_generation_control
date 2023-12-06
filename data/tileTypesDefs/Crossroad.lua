local nodesData = {
  ["NorthEntrance"] = { tags = {"tc"}, relativePosition = Vec3(400, 0, 0) },
  ["EastEntrance"] = { tags = {"tc"}, relativePosition = Vec3(0, 400, 0) },
  ["SouthEntrance"] = { tags = {"tc"}, relativePosition = Vec3(-400, 0, 0) },
  ["WestEntrance"] = { tags = {"tc"}, relativePosition = Vec3(0, -400, 0) },
}

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