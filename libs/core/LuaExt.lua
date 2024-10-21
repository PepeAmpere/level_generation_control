return {
  -- More on topic 
  -- https://stackoverflow.com/questions/15429236/how-to-check-if-a-module-exists-in-lua
  TryRequire = function(packageName)
    if package.loaded[packageName] then
      return true
    else
      for _, searcher in ipairs(package.searchers or package.loaders) do
        if type(searcher(packageName)) == "function" then
          return require(packageName)
        end
      end
    end
  end
}