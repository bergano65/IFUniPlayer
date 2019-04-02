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
    scoreStatus() -- initialize the score displayt    
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

