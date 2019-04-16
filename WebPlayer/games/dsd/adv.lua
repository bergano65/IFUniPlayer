-- Copyright (c) 2019 by Eugene Berg.  All Rights Reserved.
--  adv.lua   - standard default adventure definitions


--[[
 *   Format strings:  these associate keywords with properties.  When
 *   a keyword appears in output between percent signs (%), the matching
 *   property of the current command's actor is evaluated and substituted
 *   for the keyword (and the percent signs).  For example, if you have:
 *
 *      formatstring 'you' fmtYou;
 *
 *   and the command being processed is:
 *
 *      fred, pick up the paper
 *
 *   and the "fred" actor has fmtYou = "he", and this string is output:
 *
 *      "%You% can't see that here."
 *
 *   Then the actual output is:  "He can't see that here."
 *
 *   The format strings are chosen to look like normal output (minus the
 *   percent signs, of course) when the actor is the player character (Me).
]]--

local Luaoop = require("Luaoop")
class = Luaoop.class


fmtStrings = 
{
   "fmtYou", "you",
   "fmtYour", "your",
   "fmtYoure", "you are",
   "fmtYouve", "you have",
   "fmtS", "s",
   "fmtEs", "es",
   "fmtHave", "have",
   "fmtDo", "do",
   "fmtAre", "are",
}

--[[
 *   Special Word List: This list defines the special words that the
 *   parser needs for input commands.  If the list is not provided, the
 *   parser uses the old defaults.  The list below is the same as the old
 *   defaults.  Note - the words in this list must appear in the order
 *   shown below.
--]]

specialWords = 
{
    "of"                        --- used in phrases such as "piece of paper" 
}

--[[
 *   Forward-declare functions.  This is not required in most cases,
 *   but it doesn't hurt.  Providing these forward declarations ensures
 *   that the compiler knows that we want these symbols to refer to
 *   functions rather than objects.
 --]]
  
--[[  
--]]

--[[
 *  inputline: function
 *
 *  This is a simple cover function for the built-in function input().
 *  This cover function switches to the 'TADS-Input' font when running in
 *  HTML mode, so that input explicitly read through this function appears
 *  in the same input font that is used for normal command-line input.
--]]

function inputline()
    if currentgame == nil or currentgame.mode == "txt" then
      return io.readline()
    else
      return ""
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
 *   The die() function is called when the player dies.  It tells the
 *   player how well he has done (with his score), and asks if he'd
 *   like to start over (the alternative being quitting the game).
--]]

function die()

print("\n*** You have died ***\n")
scoreRank()
print("\nYou may restore a saved game, start over, quit, or undo the current command.\n")

end

--[[
*   checkReach: determines whether the object obj can be reached by
 *   actor in location loc, using the verb v.  Tthis routine returns true
 *   if obj is a special object (numObj or strObj), if obj is in actor's
 *   inventory or actor's location, or if it's in the 'reachable' list for
 *   loc.    
 --]]
 
 function checkReach(loc, actor, obj)
 
    if actor.isCarrying(obj) or obj.isIn(actor.location) then    
        if find(loc.reachable, obj) ~= nil then
           print ("%You% can't reach " .. eval(loc.thedescription) .. " from " .. eval(loc.thedescription) .. ".")
           return false
        end
    else
      return true
    end
 end
 
 function pardon()

    print("I beg your pardon?")
end
     
--[[

 *  listcontgen: function(obj, flags, indent)
 *
 *  This is a general-purpose object lister routine; the other object lister
 *  routines call this routine to do their work.  This function can take an
 *  object, in which case it lists the contents of the object, or it can take
 *  a list, in which case it simply lists the items in the list.  The flags
 *  parameter specifies what to do.  LCG_TALL makes the function display a "tall"
 *  listing, with one object per line; if LCG_TALL isn't specified, the function
 *  displays a "wide" listing, showing the objects as a comma-separated list.
 *  When LCG_TALL is specified, the indent parameter indicates how many
 *  tab levels to indent the current level of listing, allowing recursive calls
 *  to display the contents of listed objects.  LCG_CHECKVIS makes the function
 *  check the visibility of the top-level object before listing its contents.
 *  LCG_RECURSE indicates that we should recursively list the contents of the
 *  objects we list; we'll use the same flags on recursive calls, and use one
 *  higher indent level.  LCG_CHECKLIST specifies that we should check
 *  the listability of any recursive contents before listing them, using
 *  the standard contentsListable() test.  To specify multiple flags, combine
 *  them with the bitwise-or (|) operator.
 */
 ]]--
 
LCG_TALL = 1
LCG_CHECKVIS = 2
LCG_RECURSE = 4
LCG_CHECKLIST = 8

function listcontgen(obj, flags, indent)
  local list
  
  -- it's object list content
  if obj.type == 2 then
    list = obj.contents
  elseif obj.type == 7 then
  -- object is list itself
   list = obj
  end
   
  -- if object is open able and closed not list it's content
 local m = bit32.band(flags, LCG_CHECKVIS)
  if m ~= 0  then
     local contvis 
       contvis = not obj.isOfClass("openable")
              or (obj.isOfClass("openable") and obj.isOpened) 
              or obj.contentVisible
        if (not contvis) then
        -- we assigned to list object contents but objects isn't openable or is closed so its content isn't visible
          return
        end                            
   end
   
   local listCount = #list
   for i = listCount, 1, 1
   do
    local cur = list[i]
    -- show separated space and description of object 
     print(" ")   
     print(cur.adescription)   
     print(" ")  
     if cur.isOfClass("wearable") and cur.isWorn then
            print(" being worn")          
     end

     if cur.isOfClass("lamp") and cur.isLit then
        print("  providing light")          
     end
     
     if bit32.band(flags, LCG_RECURSE) ~= 0 then
       if table.getn(cur.contents) >= 0 then
          if cur.isOfClass("surface") then
            print(" upon which %you% see%s% ")
          else
            print("  which contains ")                                     
          end
          
          listcontgen(cur,flags,indent)
       end 
     end 
   end 

end

function sleepDaemon()
    local a, s

    currentgame.awakeTime = currentgame.awakeTime + 1
    a = currentgame.awakeTime
    s = currentgame.sleepTime

    if (a == s or a == s+10 or a == s+20) then
        print("\bYou're feeling a bit drowsy; you should find a comfortable place to sleep.")
    elseif ( a == s+25 or a == s+30 ) then
        print("\bYou really should find someplace to sleep soon, or you'll probably pass out from exhaustion. ")
    elseif ( a >= s+35 ) then
      if ( Me.location.isbed or Me.location.ischair ) then
        print("\bYou find yourself unable to stay awake any longer")
        print("Fortunately, you are ")
        if (Me.location.isbed) then 
            print("on ")
         else 
            print("in ")
            print(Me.location.adesc .. ", so you gently slip off into unconsciousness.")
            goToSleep()
         end
         end
      else
        print("\bYou find yourself unable to stay awake any longer.")
        print("You pass out, falling to the ground. ")
	    dropAll(Me)
        goToSleep()
    end
end

function eatDaemon()
    local e, l;

    if (Me.isasleep) then
        return
    end

    currentgame.lastMealTime = currentgame.lastMealTime + 1
    e = currentgame.eatTime;
    l = currentgame.lastMealTime;

    if (l == e or l == e+5 or l == e+10) then
        print("You're feeling a bit peckish. Perhaps it would be a good time to find something to eat. ")
    elseif (l == e+15 or l == e+20 or l == e+25) then
        print("You're feeling really hungry. You should find some food")
        print("soon or you'll pass out from lack of nutrition. ")
    elseif (l == e+30 or l == e+35) then
        print("You can't go much longer without food. ")
    elseif (l >= e+40) then
        print("You simply can't go on any longer without food. You perish from lack of nutrition. ")
        die()
    end
end

function turncount()

    currentgame.turns = currentgame.turns + 1  
    scoreRank();
end


--[[
 *   commonInit() - this is not a system-required function; this is simply
 *   a helper function that we define so that we can put common
 *   initialization code in a single place.  Both init() and initRestore()
 *   call this.  Since the system may call either init() or initRestore()
 *   during game startup, but not both, it's desirable to have a single
 *   function that both of those functions call for code that must be
 *   performed at startup regardless of how we're starting. 
 ]]--
 
function commonInit()
end

--[[
 *   The init() function is run at the very beginning of the game.
 *   It should display the introductory text for the game, start
 *   any needed daemons and fuses, and move the player's actor ("Me")
 *   to the initial room, which defaults here to "startroom".
]]--
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
]]--
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
]]--

function terminate()
end

--[[
 *   The pardon() function is called any time the player enters a blank
 *   line.  The function generally just prints a message ("Speak up" or
 *   some such).  This default version just says "I beg your pardon?"
]]--


--[[
 VERBS IMPLEMENTATION
]]--

local readVerb = {}
readVerb[1] = "read"
readVerb[2] = function(o, a, i)
	return true
end
readVerb[3] = function(o, a, i)
	print(eval("%You% can't read " .. eval(o.adescription) .. ". "))
end
readVerb[4] = false -- not overriden

local sayVerb = {}
sayVerb[1] = "say"
sayVerb[2] = function(o, a, i)
	return true
end
sayVerb[3] = function(o, a, i)
	print(eval("%You% said " .. eval(i) .. ". Nothing happened."))
end
sayVerb[4] = false -- not overriden

local pushVerb = {}
pushVerb[1] = "push"
pushVerb[2] = function(o, a, i)
	return true
end
pushVerb[3] = function(o, a, i)
	print(eval("Pushing " .. o.thedescription .. ". Nothing happened."))
end
pushVerb[4] = false -- not overriden



--[[
	*  The basic class for objects in a game.  The property contents
 *  is a list that specifies what is in the object; this property is
 *  automatically set up by the system after the game is compiled to
 *  contain a list of all objects that have this object as their
 *  location property.  The contents property is kept
 *  consistent with the location properties of referenced objects
 *  by the moveInto method; always use moveInto rather than
 *  directly setting a location property for this reason.  The
 *  adesc method displays the name of the object with an indefinite
 *  article; the default is to display "a" followed by the sdesc,
 *  but objects that need a different indefinite article (such as "an"
 *  or "some") should override this method.  Likewise, thedesc
 *  displays the name with a definite article; by default, thedesc
 *  displays "the" followed by the object's sdesc.  The sdesc
 *  simply displays the object's name ("short description") without
 *  any articles.  The ldesc is the long description, normally
 *  displayed when the object is examined by the player; by default,
 *  the ldesc displays "It looks like an ordinary sdesc."
 *  The isIn(object) method returns true if the
 *  object's location is the specified object or the object's
 *  location is an object whose contentsVisible property is
 *  true and that object's isIn(object) method is
 *  true.  Note that if isIn is true, it doesn't
 *  necessarily mean the object is reachable, because isIn is
 *  true if the object is merely visible within the location.
 *  The moveInto(object) method moves the object to be inside
 *  the specified object.  To make an object disappear, move it
 *  into nil.
]]--

Thing = class("Thing")

function Thing:__construct()
    self.isThem = false
    self.weight = 0
    self.statusPrep = "on"       -- give everything a default status preposition
    self.isListed = true         -- shows up in room/inventory listings
	self.description =  "thing"

    self.contents = {}           -- set up automatically by system - do not set
    self.contentsVisible = true 
    self.contents = true 
    self.location = nil
	
    self.verbTable = {}

    self.adescription = function ()
	    return "a " .. eval(self.description)
    end

  self.thedescription = function ()
      return "the " .. eval(self.description)
    end
    
  self.pluraldescription = function ()
      local d = eval(self.description)
        if (not self.isThem) then
            d = d .. "s"
            return d
        end
    end
    self.itobjdescription = function()
        if (self.isThem)  then
            return "them"
        else
            return "it"
      end 
    end
    
    self.isdescription = function()
        if (self.isThem)  then
            return "are"
        else
            return "is"
        end
    end

    self.isntdescription = function()
        if (self.isThem) then
             return "aren't"
        else
            return "isn't"
        end
    end

    self.itseldescription = function()
        if (self.isThem) then
            return "themselves"
        else
             return " itself"
        end
    end

   self.thatdescription = function()
        if (self.isThem)  then
            return "those"
        else
            return "that"
        end
    end

    self.itisdescription = function()
        if (self.isThem)  then
            return "they are"
        else
            return "it is"
        end
      end
    
    self.doesdescription = function()
        if (self.isThem)  then
            return "do"
        else
            return "does"
        end        
    end

    self.itnomdescription = function()
                if (self.isThem)  then
            return "them"
        else
            return "it"
        end        	
    end

self.multidescription = function ()
	    return eval(self.description)
    end
    
    self.longdescription = function ()
        if (self.isThem) then
            return eval(self.itnomdescription) .. " look like ordinary " .. eval(self.description) .. eval(" to %me%")
        else
            return eval(self.itnomdescription) .. " looks like ordinary " .. eval(self.description) .. eval(" to %me%")
        end
end
  
self.addVerb = function(t)
    local ind = 0
   local verbCount = #self.verbTable
   repeat
        if ind == verbCount then
            break
        end
        local v = self.verbTable[ind + 1]
        if (v[1] == t[1]) then
            self.verbTable[ind] = t
            return
        end
        ind = ind + 1
 	until (true)

    self.verbTable[#self.verbTable + 1] = t
end


self.doVerb = function(v, a, i)
    local ind = 0
   local verbCount = #self.verbTable
   repeat
        if ind == verbCount then
            break
        end
    local verb = self.verbTable[ind + 1]
    if (verb[1] == v) then
        local tryFunc = verb[2]
        if (tryFunc(self, a, i)) then
            local doFunc = verb[3]
            doFunc(self, a, i)
            return
        end
     end
     ind = ind + 1
  until (true)
end  

      -- add verbs
    self.addVerb(readVerb)
    self.addVerb(sayVerb)
    self.addVerb(pushVerb)
end


Game = class("Game")
function Game:__construct()
    self.name = "Deep Space Drifter"
    self.releasedate = '2019-01-01'
    self.license =  'Freeware'
    self.copyrules = 'Nominal Cost Only'
    self.author = "you"
    self.description = "A text adventure."
    self.mode = "txt" -- text/ui
    self.version = "1.0"
    self.player = nil
    self.turns = 0                          -- no turns have transpired so far
    self.points = 0                            -- no points have been accumulated yet
    self.startRoom = nil
    self.maxpoints = 100                                    -- maximum possible score
    self.verbose = false                             -- we are currently in TERSE mode
    self.awakeTime = 0               -- time that has elapsed since the player slept
    self.sleepTime = 400     -- interval between sleeping times (longest time awake)
    self.lastMealTime = 0              -- time that has elapsed since the player ate
    self.eatTime = 200         -- interval between meals (longest time without food)
    self.dreamList = {}

end

