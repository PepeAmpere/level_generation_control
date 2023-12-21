local nodesDefs = {
  ["NorthEntrance"] = { tags = {"tc", "north"}, relativePosition = Vec3(420, 0, 0) },
  ["End"] = { relativePosition = Vec3(0, 0, 0) },
}

local edgesDefs = {
  { edgeType = "directional", tags = {"pp"}, from = "NorthEntrance", to = "End" },
  { edgeType = "directional", tags = {"pp"}, from = "End", to = "NorthEntrance" },
}

local drawDefs = {
  "x", "w", "x",
  "x", "w", "x",
  "x", "x", "x",
}

local restrictions = {
  north = 2,
  east = 0,
  south = 0,
  west = 0,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}