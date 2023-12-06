local builders = {
  [1] = function(self, map)
    local path = map:FindPathToPositionMatchingTag(
      map:GetPositionInRoomMatchingTag("RitualRoom", "startPosition"),
      "itemPosition"
    )
    self.path = path
    self.nodeForPlacement = path:GetEndNode()
  end,
  [2] = function(self, map)
    local lighterReference = map:SpawnLighter(self.nodeForPlacement)
    self.lighterReference = lighterReference
  end,
}

return {
  builders = builders
}