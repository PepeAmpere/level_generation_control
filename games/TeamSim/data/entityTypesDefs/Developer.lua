return {
  blueprint = "/Game/Characters/Developer/BP_Pawn_NPC_Developer",
  components = {
    {name = "AI"},
    {name = "Parent"},
    {name = "Position", position = Vec3(0,0,0)},
    {name = "Vision", range = 300},
    {name = "Visible"},
  },
  offsetCorrection = Vec3(0,0,110),
}