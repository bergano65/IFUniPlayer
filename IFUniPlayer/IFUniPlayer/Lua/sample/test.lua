-- test class 

require "Luaoop"
require "adv"
require "game"

function test_thing_create()
print ("~bt~")
  local t = Thing()
  print(t.description)
end

function test_game_create()
startGame()
print(game)
print(game.description)
end


function test_callback()
print("hostSetGame")
print(hostSetGame)
print(game)
hostSetGame(game)
end

function test_oop()
local a = A()
a.left()
end

local Luaoop = require("Luaoop")
class = Luaoop.class

local A = class("A")
function A:__construct()
    print("A constructor")
    self.Left = 5

self.left = function()
  print("call LEFT")
  print(self.Left)
end
end

function  test_oop()
	local a = A()
    a.left()
end

function test_table()
	local t = {"1"}
    print("ts: " .. #t)
end


function main()
test_oop()
test_thing_create()
test_table()
test_game_create()
test_callback()
end

main()

