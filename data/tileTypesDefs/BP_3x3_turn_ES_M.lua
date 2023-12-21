local nodesDefs = {
  ["SouthEntrance"] = { tags = {"tc", "south"}, relativePosition = Vec3(-420, 0, 0) },
  ["EastEntrance"] = { tags = {"tc", "east"}, relativePosition = Vec3(0, 420, 0) },
  ["Corner"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "EastEntrance",
      "SouthEntrance",
      "Corner",
    },
  },
}

local drawDefs = {
  "x", "x", "x",
  "x", "w", "w",
  "x", "w", "x",
}

local restrictions = {
  north = 0,
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