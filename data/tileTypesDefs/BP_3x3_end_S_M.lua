local nodesDefs = {
  ["SouthEntrance"] = { tags = {"tc", "south"}, relativePosition = Vec3(-420, 0, 0) },
  ["End"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  { edgeType = "directional", tags = {"pp"}, from = "SouthEntrance", to = "End" },
  { edgeType = "directional", tags = {"pp"}, from = "End", to = "SouthEntrance" },
}

local drawDefs = {
    "x", "x", "x",
    "x", "w", "x",
    "x", "w", "x",
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
}