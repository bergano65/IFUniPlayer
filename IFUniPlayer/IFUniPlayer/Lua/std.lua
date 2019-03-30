-- Copyright (c) 2019 by Eugene Berg.  All Rights Reserved.
--  std.lua   - standard default adventure definitions
--  Version 0.1

--[[
   Pre-declare all functions, so the compiler knows they are functions.
   (This is only really necessary when a function will be referenced
    as a daemon or fuse before it is defined; however, it doesn't hurt
    anything to pre-declare all of them.) 
    ]]--

local Luaoop = require("Luaoop")
class = Luaoop.class


-- basic io functions
function print_txt(msg)

if currentgame == nil or currentgame.mode == "txt" then
  print(msg)
end

end

function eval(expr)
    if type(expr) == "function" then
        return expr()
    else
        return expr
    end
end

-- basic functions
--[[
commonInit
init
terminate
pardon
mainRestore
initRestore
]]--

--  forward declaration game class holding current game parameters and  current game 
-- local game
-- local current_game


--[[
 *   The die() function is called when the player dies.  It tells the
 *   player how well he has done (with his score), and asks if he'd
 *   like to start over (the alternative being quitting the game).
--]]

function die()

print_txt("\n*** You have died ***\n")
scoreRank()
print_txt("\nYou may restore a saved game, start over, quit, or undo the current command.\n")

end

--[[
*   The scoreRank() function displays how well the player is doing.
 *   This default definition doesn't do anything aside from displaying
 *   the current and maximum scores.  Some game designers like to
 *   provide a ranking that goes with various scores ("Novice Adventurer,"
 *   "Expert," and so forth); this is the place to do so if desired.
 *
 *   Note that "current_game.maxpoints" defines the maximum number of points
 *   possible in the game; change the property in the "global" object
 *   if necessary. 
--]]
 

 function scoreRank()

  if  currentgame == nil then
    print_txt("No current game")
    return
  end
  
  if currentgame.mode == "txt" then
    print_txt("In a total of " .. currentgame.turns) 
    print_txt("turns, you have achieved a score of " .. currentgame.points) 
    print_txt(" points out of a possible " .. currentgame.maxpoints)
  end
end

--[[
Show score
--]]

 function scoreStatus()

  if  currentgame == nil then
    print_txt("No current game")
    return
  end
  
  if currentgame.mode == "txt" then
    print_txt("In a total of " .. currentgame.turns) 
    print_txt("turns, you have achieved a score of " .. currentgame.points) 
    print_txt(" points out of a possible " .. currentgame.maxpoints)
  end
end


--[[

 *   commonInit() - this is not a system-required function; this is simply
 *   a helper function that we define so that we can put common
 *   initialization code in a single place.  Both init() and initRestore()
 *   call this.  Since the system may call either init() or initRestore()
 *   during game startup, but not both, it's desirable to have a single
 *   function that both of those functions call for code that must be
 *   performed at startup regardless of how we're starting. 
--]]
 
function commonInit()
end

--[[
 *   The init() function is run at the very beginning of the game.
 *   It should display the introductory text for the game, start
 *   any needed daemons and fuses, and move the player's actor ("Me")
 *   to the initial room, which defaults here to "startroom".
--]]
function init()

    commonInit()     
    local startRoom = getCurrentGame().startRoom
    parserGetMe().location = startRoom
    startRoom.doAction("look")
    startRoom.isSeen = true
    scoreStatus(0, 0) -- initialize the score displayt    
end

--[[
 *   initRestore() - the system calls this function automatically at game
 *   startup if the player specifies a saved game to restore on the
 *   run-time command line (or through another appropriate
 *   system-dependent mechanism).  We'll simply restore the game in the
 *   normal way.
--]]
function initRestore(fname)

    -- perform common initializations
    commonInit();

    -- tell the player we're restoring a game
    print_txt("\nRestoring saved position...\n")

    mainRestore(fname)
end    

--[[
 *   The terminate() function is called just before the game ends.  It
 *   generally displays a good-bye message.  The default version does
 *   nothing.  Note that this function is called only when the game is
 *   about to exit, NOT after dying, before a restart, or anywhere else.
--]]

function terminate()
end

--[[
 *   The pardon() function is called any time the player enters a blank
 *   line.  The function generally just prints a message ("Speak up" or
 *   some such).  This default version just says "I beg your pardon?"
--]]

function pardon()

    print_txt("I beg your pardon?")
end

    
--[[
 *   "Me" is the initial player's actor; the parser automatically uses the
 *   object named "Me" as the player character object at the beginning of
 *   the game.  We'll provide a default definition simply by creating an
 *   object that inherits from the basic player object, basicMe, defined
 *   in "adv.t".
 *   
 *   Note that you can change the player character object at any time
 *   during the game by calling parserSetMe(newMe).  You can also create
 *   additional player character objects, if you want to let the player
 *   take the role of different characters in the course of the game, by
 *   creating additional objects that inherit from basicMe.  (Inheriting
 *   from basicMe isn't required for player character objects -- you can
 *   define your own objects from scratch -- but it makes it a lot easier,
 *   since basicMe has a lot of code pre-defined for you.)  
 --]]
 
--[[
 *   commandPrompt - this displays the command prompt.  For HTML games, we
 *   switch to the special TADS-Input font, which lets the player choose
 *   the font for command input through the preferences dialog.
--]]

me = nil

function commandPrompt(code)

    -- display the normal prompt
    print_txt("\n>")
end

