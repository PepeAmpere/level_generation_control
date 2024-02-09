local nodesDefs = {}

local edgesDefs = {
  {},
}

local drawDefs = {
  "w", "w", "w",
  "w", "x", "w",
  "w", "w", "w",
}

local restrictions = {
  north = 1,
  east = 1,
  south = 1,
  west = 1,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}