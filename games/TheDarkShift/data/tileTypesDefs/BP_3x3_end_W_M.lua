local nodesDefs = {
  ["WestEntrance"] = { tags = {"tc", "west"}, relativePosition = Vec3(0, -420, 0) },
  ["End"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  { edgeType = "directional", tags = {"pp"}, from = "WestEntrance", to = "End" },
  { edgeType = "directional", tags = {"pp"}, from = "End", to = "WestEntrance" },
}

local drawDefs = {
  "x", "x", "x",
  "w", "w", "x",
  "x", "x", "x",
}

local restrictions = {
  north = 0,
  east = 0,
  south = 0,
  west = 2,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}