local WIDTH = love.graphics.getWidth()
local STEP = 40
local WIDGET_WIDTH = 150
local WIDGET_HEIGHT = 100
local WIDGET_HEIGHT_HALF = WIDGET_HEIGHT / 2
local WIDGET_HEIGHT_QUARTER = WIDGET_HEIGHT / 4

local function SinTransform(x, unitStep, yAmplitudeMax, frequency)
  return yAmplitudeMax * math.sin(x + unitStep * frequency)
end

local function CosTransform(x, unitStep, yAmplitudeMax, frequency)
  return yAmplitudeMax * math.cos(x + unitStep * frequency)
end

CalculationFunctions = {
  CosSuperSlowVar = function(widget, x, unitStep)
    return CosTransform(
      x, -- function input value
      unitStep, -- how many "units" is given pixel from X=0
      WIDGET_HEIGHT_HALF, -- amplitude
      math.sin(x/math.random(20,22))+0.01*math.abs(x%200-100)
      --((x % 40)-5)*0.2 -- frequency
    )
  end,
  SinFast = function(widget, x, unitStep)
    return SinTransform(
      x, -- function input value
      unitStep, -- how many "units" is given pixel from X=0
      WIDGET_HEIGHT_HALF, -- amplitude
      4 -- frequency
    )
  end,
  SinStandard = function(widget, x, unitStep)
    return SinTransform(
      x, -- function input value
      unitStep, -- how many "units" is given pixel from X=0
      WIDGET_HEIGHT_HALF, -- amplitude
      1 -- frequency
    )
  end,
  SinWeakFaster = function(widget, x, unitStep)
    return SinTransform(
      x, -- function input value
      unitStep, -- how many "units" is given pixel from X=0
      WIDGET_HEIGHT_QUARTER, -- amplitude
      2 -- frequency
    )
  end,
  SinWFPlusSinS = function(widget, x, unitStep)
    return CalculationFunctions.SinStandard(widget, x, unitStep) +
      CalculationFunctions.SinWeakFaster(widget, x, unitStep)
  end,
  SinSPlusSinF = function(widget, x, unitStep)
    return CalculationFunctions.SinStandard(widget, x, unitStep) +
      CalculationFunctions.SinFast(widget, x, unitStep)
  end,
  SinWFPlusSinF = function(widget, x, unitStep)
    return CalculationFunctions.SinFast(widget, x, unitStep) +
      CalculationFunctions.SinWeakFaster(widget, x, unitStep)
  end,
  SinWFPlusSinSPlusCosSS = function(widget, x, unitStep)
    return 0.3*CalculationFunctions.SinFast(widget, x, unitStep) +
      0.4*CalculationFunctions.SinWeakFaster(widget, x, unitStep) + 
      CalculationFunctions.CosSuperSlowVar(widget, x, unitStep)
  end,
}

local widgets = {
  {
    name = "Sin",
    initW = 200, initH = 100,
    width = WIDGET_WIDTH/2, height = WIDGET_HEIGHT,
    DrawFn = "Universal",
    CalcFn = "SinStandard",
  },
  {
    name = "RelaxAcc",
    initW = 300, initH = 100,
    width = WIDGET_WIDTH, height = WIDGET_HEIGHT,
    DrawFn = "Universal",
    CalcFn = "SinWeakFaster",
  },
  {
    name = "StressAcc",
    initW = 400, initH = 230,
    width = 400, height = WIDGET_HEIGHT,
    DrawFn = "Universal",
    CalcFn = "SinFast",
  },
  {
    name = "CompositeAcc",
    initW = 0, initH = 230,
    width = 300, height = 200,
    DrawFn = "Universal",
    CalcFn = "SinWFPlusSinS",
  },
  {
    name = "CompositeAcc2",
    initW = 100, initH = 400,
    width = 300, height = 200,
    DrawFn = "Universal",
    CalcFn = "SinSPlusSinF",
  },
  {
    name = "CompositeAcc3",
    initW = 300, initH = 400,
    width = 300, height = 200,
    DrawFn = "Universal",
    CalcFn = "SinWFPlusSinF",
  },
  {
    name = "CompositeAcc4",
    initW = 420, initH = 500,
    width = 800, height = 250,
    DrawFn = "Universal",
    CalcFn = "SinWFPlusSinSPlusCosSS",
  },
  {
    name = "CosSuperSlowVar",
    initW = 500, initH = 450,
    width = 800, height = 250,
    DrawFn = "Universal",
    CalcFn = "CosSuperSlowVar",
  },
}

-- local tex, clicked, held, released, hovered, mx, my, wheelx, wheely = UI2D.CustomWidget(widget.name, 150, 150)

local function GetAmplitudeFromWidth(width)
  return math.floor(OneSim.t + width / STEP)
end
drawFunctions = {
  Universal = function (widget, winName, tex, held, hovered, mx, my)
    local w,h = UI2D.GetWindowPosition(winName)
    local y = widget.height/2
    local y2 = widget.height
    local CalcFn = CalculationFunctions[widget.CalcFn]

    local col = { 0, 0, 0 }
    love.graphics.setCanvas(tex)
    love.graphics.clear(col)
    love.graphics.setColor(1, 1, 1)

    for i = 1, widget.width do
      local unitStep = ((w + i) / STEP)
      local yy = y + CalcFn(widget, OneSim.t, unitStep)
      love.graphics.setColor((yy)/y2, (y2-yy)/y2, 0)
      love.graphics.points(i, yy)
    end
  end,
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
    --UI2D.Label("Sim time: " .. math.floor(OneSim.t * 10) / 10)
    --UI2D.Label("Sim step: " .. math.floor(OneSim.step * 10) / 10)
    UI2D.Label("Sim time: " .. OneSim.t)
    UI2D.Label("Sim step: " .. OneSim.step)
    UI2D.End()
  end,

  Widgets = function()
    for i = 1, #widgets do
      local widget = widgets[i]
      local windowName = widget.name .. "[" .. widget.CalcFn .. "]"
      UI2D.Begin(windowName, widget.initW, widget.initH)
      local tex, _, held, _, hovered, mx, my, _, _ = UI2D.CustomWidget(
        widget.name,
        widget.width, widget.height
      )
      drawFunctions[widget.DrawFn](
        widget,
        windowName,
        tex, held, hovered, mx, my
      )
      UI2D.End()
    end
  end,
}
