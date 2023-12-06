local builders = {
  [1] = function(q, map)
    q.reachEdge = map:CreateReachDFS(
      map:GetPositionInRoomMatchingTag("RitualRoom", "startPosition"), -- start position
      
      8, -- tiles travel max
      nil -- only allowed
    )
  end,
  [2] = function(q, map)
    local path = map:FindPathToPositionMatchingTag(
      map:GetPositionInRoomMatchingTag("RitualRoom", "startPosition"),
      "spotBeforeExit"
    )
    self.path = path
    self.nodeForPlacement = path:GetEndNode()
  end,
  [3] = function(self, map)
    local lighterReference = map:SpawnLighter(self.nodeForPlacement)
    self.lighterReference = lighterReference
  end,
}

return {
  builders = builders
}