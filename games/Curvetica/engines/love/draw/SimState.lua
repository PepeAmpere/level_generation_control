local WIDTH = love.graphics.getWidth()
local STEP = 40
local WIDGET_WIDTH = 150
local WIDGET_HEIGHT = 100
local widgets = {
  {
    name = "RelaxAcc",
    initW = 300, initH = 100,
    width = WIDGET_WIDTH, height = WIDGET_HEIGHT,
    drawFn = "NewSin",
    fnParams = {amplitude = STEP/2, frequency = STEP, offset = 0},
  },
  {
    name = "StressAcc",
    initW = 300, initH = 250,
    width = 400, height = WIDGET_HEIGHT,
    drawFn = "NewSin",
    fnParams = {amplitude = STEP, frequency = STEP/2, offset = 0},
  },
  {
    name = "CompositeAcc",
    initW = 100, initH = 350,
    width = 300, height = 200,
    drawFn = "Composite",
    fnParams = {amplitude = STEP, frequency = STEP/2, offset = 0},
  },
}

-- local tex, clicked, held, released, hovered, mx, my, wheelx, wheely = UI2D.CustomWidget(widget.name, 150, 150)

local function GetAmplitudeFromWidth(width)
  return math.floor(OneSim.t + width / STEP)
end
local amplitude = STEP
local frequency = 0.1
drawFunctions = {
  Composite = function(winName, tex, held, hovered, mx, my, widgetParams)
    local w,h = UI2D.GetWindowPosition(winName)
    local val = GetAmplitudeFromWidth(w)
    local y = widgetParams.height/2
    local y2 = widgetParams.height

    local col = { 0, 0, 0 }
    love.graphics.setCanvas(tex)
    love.graphics.clear(col)
    love.graphics.setColor(1, 1, 1)

    for i = 1, widgetParams.width do
      local yy = y +
      STEP/2 * math.sin((OneSim.t + (w + i) / STEP)) +
      STEP * math.sin((OneSim.t + (w + i) / (STEP/2)))
      love.graphics.setColor((yy)/y2, (y2-yy)/y2, 0)
      love.graphics.points(i, yy)
    end
  end,
  DrawSinus = function(winName, tex, held, hovered, mx, my, widgetParams)
    if held then
      amplitude = (75 * my) / 150
      frequency = (0.2 * mx) / 250
    end

    local col = { 0, 0, 0 }
    if hovered then
      col = { 0.1, 0, 0.2 }
    end

    -- Prepare this custom-widget's canvas
    love.graphics.setCanvas(tex)
    love.graphics.clear(col)
    love.graphics.setColor(1, 1, 1)

    local xx = 0
    local yy = 0
    local y = widgetParams.height/2

    for i = 1, widgetParams.width do
      yy = y + (amplitude * math.sin(frequency * xx))
      love.graphics.points(xx, yy)
      xx = xx + 1
    end
  end,
  NewSin = function(winName, tex, held, hovered, mx, my, widgetParams)
    local w,h = UI2D.GetWindowPosition(winName)
    local val = GetAmplitudeFromWidth(w)
    local y = widgetParams.height/2
    local y2 = widgetParams.height

    local col = { 0, 0, 0 }
    love.graphics.setCanvas(tex)
    love.graphics.clear(col)
    love.graphics.setColor(1, 1, 1)

    for i = 1, widgetParams.width do
      local yy = y + widgetParams.fnParams.amplitude * math.sin((OneSim.t + (w + i) / widgetParams.fnParams.frequency))
      love.graphics.setColor((yy)/y2, (y2-yy)/y2, 0)
      love.graphics.points(i, yy)
    end
  end,
  DrawTimeline = function(winName, tex, held, hovered, mx, my, widgetParams)
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
    drawFunctions["DrawTimeline"](windowName, tex, held, hovered, mx, my)
    UI2D.End()
  end,

  TimeData = function(w, h)
    UI2D.Begin("Sim info", w, h)
    --UI2D.Label("Sim time: " .. math.floor(OneSim.t * 10) / 10)
    --UI2D.Label("Sim step: " .. math.floor(OneSim.step * 10) / 10)
    UI2D.Label("Sim time: " .. OneSim.t)
    UI2D.Label("Sim step: " .. OneSim.step)
    UI2D.End()
  end,

  Widgets = function()
    for i = 1, #widgets do
      local widget = widgets[i]
      local windowName = widget.name .. "Window"
      UI2D.Begin(windowName, widget.initW, widget.initH)
      local tex, _, held, _, hovered, mx, my, _, _ = UI2D.CustomWidget(
        widget.name,
        widget.width, widget.height
      )
      drawFunctions[widget.drawFn](
        windowName,
        tex, held, hovered, mx, my,
        widget
      )
      UI2D.End()
    end
  end,
}
