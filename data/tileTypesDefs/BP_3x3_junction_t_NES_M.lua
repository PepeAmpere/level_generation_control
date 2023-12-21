local nodesDefs = {
  ["NorthEntrance"] = { tags = {"tc","north"}, relativePosition = Vec3(420, 0, 0) },
  ["EastEntrance"] = { tags = {"tc", "east"}, relativePosition = Vec3(0, 420, 0) },
  ["SouthEntrance"] = { tags = {"tc", "south"}, relativePosition = Vec3(-420, 0, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "NorthEntrance",
      "EastEntrance",
      "SouthEntrance",
    },
  },
}

local drawDefs = {
  "x", "w", "x",
  "x", "w", "w",
  "x", "w", "x",
}

local restrictions = {
  north = 2,
  east = 2,
  south = 2,
  west = 0,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}