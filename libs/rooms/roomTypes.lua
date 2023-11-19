return {
  ["blocked1"] = {
    description = "",
    className = "???",
    doors = {},
    displayColor = {0,0,0},
  },
  ["blocked2"] = {
    description = "",
    className = "???",
    doors = {},
    displayColor = {0,0,0},
  },
  ["blocked3"] = {
    description = "",
    className = "???",
    doors = {},
    displayColor = {0,0,0},
  },
  
  ["kitchen"] = {
    description = "A cozy kitchen with a dead bodies parts and Loomis",
    className = "BP_3x3_kitchen",
    doors = {
      west = true,
      south = true,
    },
    displayColor = {192,0,0},
  },

  ["ritualRoom"] = {
    description = "...",
    className = "BP_3x3_kitchen",
    doors = {
      east = true,
      south = true,
    },
    displayColor = {218,218,218},
  },

  ["restroomMale"] = {
    description = "...",
    className = "BP_3x3_restroom_male",
    doors = {
      south = true,
    },
    displayColor = {64,64,192},
  },

  ["restroomFemale"] = {
    description = "...",
    className = "BP_3x3_restroom_female",
    doors = {
      south = true,
    },
    secretDoors = {
      north = true,
    },
    displayColor = {192,64,192},
  },

  ["exitRoom"] = {
    description = "...",
    className = "BP_3x3_exit_door_R_E_M",
    doors = {
      east = true,
    },
    displayColor = {255,255,192},
  },

  ["officeRoom"] = {
    description = "...",
    className = "BP_3x3_office",
    doors = {
      north = true,
    },
    secretDoors = {
      south = true,
    },
    displayColor = {0,192,192},
  },

  ["dinnersLeft"] = {
    description = "...",
    className = "BP_3x3_diner_entrance",
    doors = {
      north = true,
      west = true,
    },
    displayColor = {64,64,64},
  },

  ["dinnersRight"] = {
    description = "...",
    className = "BP_3x3_diner_table_area",
    doors = {
      west = true,
    },
    displayColor = {64,64,64},
  },

  ["undefined"] = {
    description = "...",
    className = "...",
    doors = {
      north = true,
      west = true,
      south = true,
      east = true,
    },
    displayColor = {32,32,32},
  },
}