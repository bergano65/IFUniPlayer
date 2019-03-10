local Object = {} -- the table representing the class, which will double as the metatable for the instances
Object.__index = Object -- failed table lookups on the instances should fallback to the class table, to get methods

-- syntax equivalent to "MyClass.new = function..."
function Object.new()
  local self = setmetatable({}, Object)
  return self
end

Object.name = "Thing"

Object.actionTable = {}

-- verbs associated handlers

lookTable = {}
lookTable.execute = function()
  print "Ordinary $(self.name). Nothing outstanding"
end

Object.actionTable["look"] = lookTable

Object.doAction = function(verb)

  local action = self.actionTable[verb]
  if (action ~= nil)
  then
    action.execute()
  end 
end