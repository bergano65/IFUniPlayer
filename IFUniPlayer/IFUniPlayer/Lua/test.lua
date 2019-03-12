-- test class 

require "std"
require "adv"


function test_input()
  local i = inputline()
end

function test_print()
  print_txt("Hello InsteadMod")
end

function test_die()
  die()
end

function test_game_create()
  local g = currentgame
  print(g)
end

local Luaoop = require("Luaoop")
class = Luaoop.class

local A = class("A")
function A:__construct()
    print("A constructor")
end

function A:left()
  print("call LEFT")
end

function test_oop()    
    local a = A()
    a.left()
end

function test_thing_description()
  local t = Thing()
  print(eval(t.adescription))
  print(eval(t.thedescription))  
  print(eval(t.pluraldescription))
  print(eval(t.itobjdescription))
  print(eval(t.isdescription))
  print(eval(t.isntdescription))
  print(eval(t.itseldescription))
  print(eval(t.thatdescription))
  print(eval(t.itisdescription))
  print(eval(t.doesdescription))
end

local function main()
    test_oop()
  test_thing_description()
  test_input()
  test_print()
test_game_create()
 test_die()
end

main()

