--[[
 *  Port of TADS game to IFAnywhere. Copyright remained appropriate owners.
 *   Copyright (c) 1989, 1999 by Michael J. Roberts and Steve McAdams.
 *   All Rights Reserved.
 *   
 *   Deep Space Drifter - TADS Interactive Fiction
 ]]--

require "adv"
require "Luaoop"

game = nil

function startGame()
    game = Game()
    game.name = "Deep Space Drifter"
    game.releasedate = '1990-01-01'
    game.license =  'Freeware'
    game.copyrules = 'Nominal Cost Only'
    game.author = "Michael J. Roberts and Steve McAdams"
    game.description = "A classic science fiction text adventure.  Stranded after running out of fuel, you must try to get help from a nearby space station, but the place is abandoned and strange things seem to have been happening lately. Find a way down to the planet if you dare"
    game.mode = "txt" -- text/ui
    game.version = "1.0"
    game.player = nil
    game.turns = 0                          -- no turns have transpired so far
    game.points = 0                            -- no points have been accumulated yet
    game.startRoom = nil
    game.maxpoints = 100                                    -- maximum possible score
    game.verbose = false                             -- we are currently in TERSE mode
    game.awakeTime = 0               -- time that has elapsed since the player slept
    game.sleepTime = 400     -- interval between sleeping times (longest time awake)
    game.lastMealTime = 0              -- time that has elapsed since the player ate
    game.eatTime = 200         -- interval between meals (longest time without food)

print(hostSetGame)
    if (hostSetGame ~= nil) then
        hostSetGame(game)
    end
end

function dropAll(actor)

    local cur, rem, loc, cnt
    
    cnt = 0
    rem = actor.contents
    loc = actor.location
    local i = 1

        if o.doVerb("move", actor, loc) then
            repeat
                local o = rem[i]

                if i == (#rem + 1) then
                    break
                end
                i = i + 1
            until (true)
       end
end

function stationShake()
  local severity

  if (not Me.isasleep ) then -- suppress explosion while dreaming
    print("\r\n")
    if (not Me.isvac) then
        local severity = rand(10)
        if (severity == 1) then
            print("The station shakes slightly, as though some large object hit the exterior.")
        elseif (severity < 4) then
            print("A loud crashing sound explodes all around you. The whole room shakes violently for several moments. The shaking eventually subsides. ")
        elseif (severity < 10) then
            print("A terrifying roar suddenly rips through the station, as though a huge explosion had just happened nearby. The floor buckles and the room seems to spin. For long moments, the room rumbles and            shakes. Eventually, the shaking subsides, and you take a moment to regain your balance.")
        else
            print("The room is suddenly jolted with a huge shock. The lights go out")
            print("and the whole station seems to spin and flip end over end. You")
            print("reach in vain for something to hold on to, but the whole room seems")
            print("to be spinning. After a few moments, the lights come back on, and")
            print("the station seems to recover normal gravity; the r  umbling and")
            print("shaking continue for several more moments, the structure of the")
            print("station creaking and moaning the whole time. Eventually, things")
            print("seem to return to normal")
	    
	        dropAll(Me)
        end
    else
        print("There is a brilliant flash of light, and the station shakes")
        print("violently. You don't know how, but somehow you manage to avoid")
        print("floating out into space. After a few moments, the shaking stops. ")
    end 
  end
  setfuse(stationShake, rand(4) + 3, nil)  -- reset fuse in 3-7 turns */
end

function darkTravel()
    print("You stumble around in the dark, and don't get anywhere. ")
end

function gameinit()
    
    print("It was a more exciting time, back in the early years of deep space")
    print("expploration. Anyone who could afford a good ship and a tank full")
    print("of fuel could strike out into the vast empty reaches to find his")
    print("fortune among the stars")
    print("Of course, you'd have a better chance of finding your fortune")
    print("if you had remembered to check a nav chart before heading off")
    print("the void. Now you're nearly out of fuel and air, you're")
    print("tired and hungry -- and desperately hoping you can find someone monitoring the distress channels.")
    print("\r\nCopyright (c) 1988, 1990 by Michael J. Roberts and Steve McAdams.")
    print("\r\nAll Rights Reserved.\r\n")

    setdaemon(turncount, nil)
    setdaemon(sleepDaemon, nil)
    setdaemon(eatDaemon, nil)
    setfuse(shipDie, 15, nil)
    setdaemon(vacDaemon, nil)
    game.sleepList[#global.sleepList + 1] = vacRobot
    startBelt.isfastened = true
    startChair.fastenitem = startBelt
    Me.location = startChair
    Me.cantSleep = true

    game.dreamList = global.dreamList + swampDream + xeniteDream;

    -- set up globals
    initSearch()
end

function shipland(parm)
    print("A sudden shock reverberates through your ship. \"Warning,\" the")
    print("ship's computer announces, \"near miss by energy beam weapon.\" You hold")
    print("on, hoping it doesn't get any closer, knowing there's not anything you")
    print("can do with so little fuel.")
    print("\r\n\tYour ship shudders for a moment as the rockets suddenly")
    print("fire. The rockets stop, and a few moments later a loud")
    print("thud resounds throughout the ship. \"Docking completed,\"")
    print("the tinny computer voice announces.")
    startroom.isdocked = true
    incscore(5)
    setfuse(stationShake, rand(4)+3, nil)
end
 
function stopCycle(parm)

    if ((not stationAir.iscycled) and cycleButton.armState == 1) then
        if (Me.location == stationAir) then
            print("\n\tA mechanical voice announces, \"The airlock cycle")
            print("is no longer armed. Press the cycle button to")
            print("re-initiate the airlock cycle.\"")
        end
        cycleButton.armState = 0 -- ??
    end
end

function suffowarn(parm)
    if (Me.location.isvac) then
        print("\r\n\t")
        if (suitTank.location == spacesuit) then
            print("Your air tank doesn't seem to be working too well.")
            print("You did check that it was full before you attempted")
            print("extra vehicular activity, didn't you? ")
        else
            print("When going into a vacuum environment, you recall")
            print("from your Pilot Ed class back in high school,")
            print("always bring along an oxygen tank. Which you")
            print("forgot to do. Consequently, you are getting quite")
            print("short on air. ")
        end
        setfuse(suffowarn2, 2, nil)
        end
end

function suffodo(parm)
    if (Me.location.isvac) then
        print("\n\tYou pass out from lack of oxygen, but not until")
        print("you've had the opportunity to fog up your helmet's")
        print("faceshield with your industrious panting and carrying")
        print("on. ")
        
        remdaemon(airLight, nil)
        die()
    end
end
