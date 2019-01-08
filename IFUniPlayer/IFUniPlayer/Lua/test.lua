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


local function main()
  test_input()
  test_print()
test_game_ncreate()
 test_die()
end

main()

