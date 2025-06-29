-- hardreferenced globals
-- UI_STATES
-- CENTER_X
-- ABOVE_NODE_Y

local function MakePartsVertices(x, y, model, scale)
  local partsVertices = {}
  for part, vertices in pairs(model) do
    partsVertices[part] = {}
    for i = 0, #vertices - 1 do
      partsVertices[part][2 * i + 1] = x + scale * vertices[i + 1]:X()
      partsVertices[part][2 * i + 2] = y + scale * vertices[i + 1]:Y()
    end
  end
  return partsVertices
end

local function RotateTemplate(template, angle)
  local angleSin, angleCos = math.sin(angle), math.cos(angle)

  local rotatedTemplate = {}
  for part, vertices in pairs(template) do
    rotatedTemplate[part] = {}
    for i = 1, #vertices do
      local newX = vertices[i]:X() * angleCos - vertices[i]:Y() * angleSin
      local newY = vertices[i]:X() * angleSin + vertices[i]:Y() * angleCos
      rotatedTemplate[part][i] = Vec3(newX, newY, 0)
    end
  end
  return rotatedTemplate
end

return {
  Coordinates = function(simPosition)
    local stringToWrite = tostring(simPosition)
    local x, y = simPosition:ToPixel()
    local drawCoords = Vec3(x, y, 0)
    if UI_STATES.textfields[stringToWrite] then
      local textColor = { 0.5, 1, 0.5, 1 }
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
  DebugUIStates = function()
    local w, h = love.graphics.getDimensions()

    -- top left corner
    local halfTop = h/4
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.rectangle("fill", 0, halfTop, 200, 65)
    love.graphics.setColor(0, 0, 0, 1)
    local counter = 0
    for k,v in pairs(UI_STATES) do
      love.graphics.print(tostring(k) .. ": " .. tostring(v), 0, halfTop + counter*10)
      counter = counter + 1
    end
  end,
  NodeSelected = function(selectedHexKey, scale)
    local selectedHexPosition = levelMap:GetAnyHexPosition(selectedHexKey, "_")
    local vertices = selectedHexPosition:ToCorners(scale * 0.9)
    local latestColor = { 0.7, 0.7, 0.7, 0.5 }
    love.graphics.setLineWidth(10)
    love.graphics.setLineStyle("rough")
    Draw.Polygon(
      vertices,
      latestColor,
      "line"
    )
  end,
  NodeShape = function(node, scale)
    local hexCoords = node:GetPosition()
    local vertices = hexCoords:ToCorners(scale * 0.8)

    local latestColor = { 0.5, 1, 0.5, 0.5 }
    local hexTypeName
    if node:GetTagValue("hexTypeName") then
      hexTypeName = node:GetTagValue("hexTypeName")
      latestColor = HexTypes[hexTypeName].drawDefs.color
    end
    Draw.Polygon(
      vertices,
      latestColor
    )

    if hexTypeName ~= "mapSea" then
      local basex, basey = hexCoords:ToPixel()
      local randomDirection = node:GetTagValue("randomDirection")
      local secondx = vertices[(randomDirection-1)*2 + 1]
      local secondy = vertices[(randomDirection-1)*2 + 2]

      local latestColor = { 1, 0.2, 0.2, 0.5 }
      Draw.Line(
        Vec3(basex, basey, 0),
        Vec3(secondx, secondy, 0),
        2,
        latestColor
      )
    end
  end,
  PersonAll = function(camera, sensorName, phase)
    local angle = camera:getAngle()
    local parts = {}
    local colors = {}

    for typeName, typeDef in pairs(EntityTypes) do
      local partsTemplate, colorsTemplate = typeDef.LoveDraw[sensorName](phase)
      local rotatedTemplate = RotateTemplate(partsTemplate, angle)
      parts[typeName] = rotatedTemplate
      colors[typeName] = colorsTemplate
    end

    local allEntities = OneSim:GetEntities()

    for entityID, entity in pairs(allEntities) do
      local scale = 5
      local position = entity:GetComponent("Position"):Get()
      local typeName = entity:GetTypeName()
      local rotatedTemplate = parts[typeName]
      local color = colors[typeName]

      local partsVertices = MakePartsVertices(
        position:X(),
        position:Y(),
        rotatedTemplate,
        scale
      )
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
