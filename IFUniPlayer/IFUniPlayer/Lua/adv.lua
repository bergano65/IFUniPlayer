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
--]]

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
function checkDoor
function checkReach
function itemcnt
function isIndistinguishable
function sayPrefixCount
function listcont
function nestlistcont
function listcontcont
function turncount
function addweight
function addbulk
function incscore
function scoreRank
function terminate
function goToSleep
function initSearch
function reachableList
function initRestart
function contentsListable
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
           print ("%You% can't reach " .. obj.thedesc .. " from " .. loc.thedescription .. ".")
           return false
        end
    else
      return true
    end
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
   
   local listCount = table.getn(list)
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

function turncount()

    currentgame.turns = currentgame.turns + 1  
    scoreStatus(currentgame.turns, currentgame.points);
end

