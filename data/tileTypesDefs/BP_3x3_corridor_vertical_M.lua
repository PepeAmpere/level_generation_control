local nodesDefs = {
  ["NorthEntrance"] = { tags = {"tc","north"}, relativePosition = Vec3(420, 0, 0) },
  ["SouthEntrance"] = { tags = {"tc", "south"}, relativePosition = Vec3(-420, 0, 0) },
  ["Middle"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  {
    edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "NorthEntrance",
      "Middle",
      "SouthEntrance",
    },
  },
}

local drawDefs = {
  "x", "w", "x",
  "x", "w", "x",
  "x", "w", "x",
}

local restrictions = {
  north = 2,
  east = 0,
  south = 2,
  west = 0,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}