local nodesDefs = {
  ["WestEntrance"] = { tags = {"tc", "west"}, relativePosition = Vec3(0, -420, 0) },
}

local edgesDefs = {
  {},
}

local drawDefs = {
  "w", "w", "x",
  "w", "w", "x",
  "w", "w", "x",
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