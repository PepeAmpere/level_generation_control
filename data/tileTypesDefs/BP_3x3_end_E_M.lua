local nodesDefs = {
  ["EastEntrance"] = { tags = {"tc", "east"}, relativePosition = Vec3(0, 420, 0) },
  ["End"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  { edgeType = "directional", tags = {"pp"}, from = "EastEntrance", to = "End" },
  { edgeType = "directional", tags = {"pp"}, from = "End", to = "EastEntrance" },
}

local drawDefs = {
  "x", "x", "x",
  "x", "w", "w",
  "x", "x", "x",
}

local restrictions = {
  north = 0,
  east = 2,
  south = 0,
  west = 0,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}