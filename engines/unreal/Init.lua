-- custom libs cleanup to reload them with each play session
for packageName,_ in pairs(package.loaded) do
  if
    string.find(packageName, "libs") or
    string.find(packageName, "games") or
    string.find(packageName, "engines") or
    string.find(packageName, "main")
  then
    print("Unloading " .. packageName)
    package.loaded[packageName] = nil
  end
end

return true