local WIDTH = love.graphics.getWidth()
local STEP = 40
local WIDGET_WIDTH = 150
local WIDGET_HEIGHT = 100
local WIDGET_HEIGHT_HALF = WIDGET_HEIGHT / 2
local WIDGET_HEIGHT_QUARTER = WIDGET_HEIGHT / 4

local widgets = {}

-- local tex, clicked, held, released, hovered, mx, my, wheelx, wheely = UI2D.CustomWidget(widget.name, 150, 150)

local function GetAmplitudeFromWidth(width)
  return math.floor(OneSim.t + width / STEP)
end

drawFunctions = {
  DrawTimeline = function(widget, winName, tex, held, hovered, mx, my)
    local newZero = OneSim.t
    local newDelta = math.floor(math.ceil(OneSim.t) - OneSim.t * STEP)

    love.graphics.setCanvas(tex)
    love.graphics.clear(col)
    love.graphics.setColor(1, 1, 1)

    for i = 1, WIDTH do
      if ((i - newDelta) % STEP) == 0 then
        local stepX = (i - newDelta) % STEP
        love.graphics.points(i, 10)
        love.graphics.print(GetAmplitudeFromWidth(i), i-5, 20, 0, 0.8, 0.8)
      end
    end
  end,
}

return {
  Timeline = function(w, h)
    local windowName = "Timeline"
    UI2D.Begin(windowName, w, h)
    local tex, _, held, _, hovered, mx, my, _, _ = UI2D.CustomWidget(
      "Timeline-itself",
      WIDTH, 40
    )
    drawFunctions["DrawTimeline"](_, windowName, tex, held, hovered, mx, my)
    UI2D.End()
  end,

  TimeData = function(w, h)
    UI2D.Begin("Sim info", w, h)
    UI2D.Label("Sim time: " .. OneSim.t)
    UI2D.Label("Sim step: " .. OneSim.step)
    UI2D.End()
  end,

  DebugUpdate = function(entities)
    for entityID, entity in pairs(entities) do
      local DebugComponent = entity:GetComponent("DebugScreen")
      if DebugComponent then
        if DebugComponent:IsEmpty() then
          DebugComponent:Add(1, function(p) UI2D.Begin(p.widgetName, p.w, p.h) end)
          DebugComponent:Add(2, function(p) UI2D.Label("Position " .. p.pos) end)
          DebugComponent:Add(3, function(p)
              for k,v in pairs(p.bb) do
                UI2D.Label(k .. ": " .. v, true)
              end
          end)
          DebugComponent:Add(4, function(p) UI2D.End() end)
        else
          local widgetName = "w" .. entityID
          local position = entity:GetComponent("Position")
          local pos = position:Get()
          local bbComponent = entity:GetComponent("BB")
          local bb = bbComponent:Get()
          local p = {
            widgetName = widgetName,
            eID = entityID,
            pos = pos:X() .. "|" .. pos:Y() .. "|" .. pos:Z(),
            bb = bb,
            w = pos:X(), -- mainly init
            h = pos:Y(), -- mainly init
          }
          DebugComponent:Draw(p)

          -- temporary => use this to push back sim data about position
          local w,h = UI2D.GetWindowPosition(widgetName)
          position:Set(Vec3(w,h,0))
        end
      end
    end
  end,
}
