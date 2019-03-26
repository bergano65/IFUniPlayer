-- test class 

require "std"
require "adv"
require "game"

function test_game_create()
  createGame()
  print(game)
end

local function main()
test_game_create()
end

main()

