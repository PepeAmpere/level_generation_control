return {

  ConvertToTable = function(array)
    local tbl = {}
    for i=1, #array do
      tbl[array[i]] = true
    end
    return tbl
  end,

  JoinCopy = function(arrayOne, arrayTwo)
    local tbl = {}
    for i=1, #arrayOne do
      tbl[#tbl + 1] = arrayOne[i]
    end
    for i=1, #arrayTwo do
      tbl[#tbl + 1] = arrayTwo[i]
    end
    return tbl
  end,

  ShallowCopy = function(array)
    local newArray = {}
    for i=1, #array do
      newArray[i] = array[i]
    end
    return newArray
  end,

  Shuffle = function(array)
    for i = #array, 2, -1 do
      local j = math.random(i)
      array[i], array[j] = array[j], array[i]
    end
    return array
  end
}