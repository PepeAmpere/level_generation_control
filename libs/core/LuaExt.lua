return {
  -- More on topic 
  -- https://stackoverflow.com/questions/15429236/how-to-check-if-a-module-exists-in-lua
  -- https://stackoverflow.com/questions/15154740/how-to-gracefuly-try-to-load-packages-in-lua
  -- https://stackoverflow.com/questions/34965863/lua-require-fallback-error-handling
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