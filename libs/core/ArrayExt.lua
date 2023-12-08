return {
  ShallowCopy = function(array)
    local newArray = {}
    for i=1, #array do
      newArray[i] = array[i]
    end
    return newArray
  end,
  ConvertToTable = function(array)
    local tbl = {}
    for i=1, #array do
      tbl[array[i]] = true
    end
    return tbl
  end,
}