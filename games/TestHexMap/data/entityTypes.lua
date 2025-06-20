return {
  Person = {
    components = {
      {name = "AI"},
      {name = "Parent"},
      {name = "Position"},
      {name = "Vision", range = 300},
      {name = "Visible"},
      -- {name = "PathPhase", phase = 0},
    },
    -- love specific
    LoveDraw = {
      Eye = function(phase)
        local correction = Vec3(-1.5, 1.5, 0)
        local parts = {
          body = {
            Vec3(0, 0, 0) + correction,
            Vec3(3, 0, 0) + correction,
            Vec3(3, -3, 0) + correction,
            Vec3(0, -3, 0) + correction,
          },
          neck = {
            Vec3(0, -3+phase, 0) + correction,
            Vec3(1, -3+phase, 0) + correction,
            Vec3(1, -4+phase, 0) + correction,
            Vec3(0, -4+phase, 0) + correction,
          },
          head = {
            Vec3(0, -4+phase, 0) + correction,
            Vec3(3, -4+phase, 0) + correction,
            Vec3(3, -5+phase, 0) + correction,
            Vec3(0, -5+phase, 0) + correction,
          }
        }
        local color = {1, 0, 0.5, 1}
        return parts, color
      end,
      ElectroOptic = function(phase)
        local parts = {
          body = {
            Vec3(-2, 1, 0),
            Vec3(2, 1, 0),
            Vec3(2, -1, 0),
            Vec3(-2, -1, 0),
          },
          body2 = {
            Vec3(-1, 2, 0),
            Vec3(1, 2, 0),
            Vec3(1, -2, 0),
            Vec3(-1, -2, 0),
          }
        }
        local color = {1, 0, 0.5, 0.5}
        return parts, color
      end,
      SAR = function(phase)
        local parts = {
          body = {
            Vec3(-2, 1, 0),
            Vec3(2, 1, 0),
            Vec3(2, -1, 0),
            Vec3(-2, -1, 0),
          },
          body2 = {
            Vec3(-1, 2, 0),
            Vec3(1, 2, 0),
            Vec3(1, -2, 0),
            Vec3(-1, -2, 0),
          }
        }
        local color = {0.5, 0.5, 0.5, 0.5}
        return parts, color
      end
    },
  }
}