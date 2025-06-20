-- hardreferenced globals
-- UI_STATES
-- CENTER_X
-- ABOVE_NODE_Y

local function MakePartsVertices(x, y, model, scale)
  local partsVertices = {}
  for part, vertices in pairs(model) do
    partsVertices[part] = {}
    for i=0, #vertices-1 do
      partsVertices[part][2*i+1] = x + scale * vertices[i+1]:X()
      partsVertices[part][2*i+2] = y + scale * vertices[i+1]:Y()
    end
  end
  return partsVertices
end

local function RotateTemplate(template, angle)
  local angleSin, angleCos = math.sin(angle), math.cos(angle)

  local rotatedTemplate = {}
  for part, vertices in pairs(template) do
    rotatedTemplate[part] = {}
    for i=1, #vertices do
      local newX = vertices[i]:X() * angleCos - vertices[i]:Y() * angleSin
      local newY = vertices[i]:X() * angleSin + vertices[i]:Y() * angleCos
      rotatedTemplate[part][i] = Vec3(newX, newY, 0)
    end
  end
  return rotatedTemplate
end

return {
  Coordinates = function(simPosition, scale)
    local stringToWrite = tostring(simPosition)
    local x,y = simPosition:ToPixel(scale)
    local drawCoords = Vec3(x,y,0)
    if UI_STATES.textfields[stringToWrite] then
      local textColor = {0.5, 1, 0.5, 1}
      Draw.Text(
        UI_STATES.textfields[stringToWrite],
        drawCoords + Vec3(CENTER_X, ABOVE_NODE_Y, 0),
        textColor
      )
    else
      local text = love.graphics.newText(love.graphics.getFont(), stringToWrite)
      UI_STATES.textfields[stringToWrite] = text
    end
  end,
  NodeShape = function(node, scale)
    local hexCoords = node:GetPosition()
    local vertices = hexCoords:ToCorners(scale, scale*0.8)

    local latestColor = {0.5, 1, 0.5, 0.5}
    if node:GetTagValue("nodeType") then
      nodeType = node:GetTagValue("nodeType")
      latestColor = nodeType.drawDefs.color
    end
    Draw.Polygon(
      vertices,
      latestColor
    )
  end,
  PersonAll = function(camera, sensorName, phase)
    local angle = camera:getAngle()

    local partsTemplate, colorsTemplate = EntityTypes.Person.LoveDraw[sensorName](phase)
    local rotatedTemplate = RotateTemplate(partsTemplate, angle)

    local allEntities = OneSim:GetEntities()

    for entityID, entity in pairs(allEntities) do
      local scale = 5
      local phase = phase or 1
      local position = entity:GetComponent("Position"):Get()

      local partsVertices = MakePartsVertices(
        position:X(),
        position:Y(),
        rotatedTemplate,
        scale
      )
      local color = colorsTemplate
      for part, vertices in pairs(partsVertices) do
        love.graphics.setColor(color[1], color[2], color[3], color[4])
        love.graphics.polygon("fill", vertices)
        --Draw.Polygon(
        --  vertices,
        --  latestColor
        --)
      end
    end
  end
}

