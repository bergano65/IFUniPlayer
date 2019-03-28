-- test class 

require "std"
require "adv"
require "game"

function test_thing_create()
  local t = Thing()
end

function test_game_create()
startGame()
print(game)
end

local function main()
--test_oop()
test_thing_create()
test_game_create()
end

main()

