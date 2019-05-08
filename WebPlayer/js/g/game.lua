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
    game.backgroundImage = "bck.jpg"

    return game
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
    print("A sudden shock reverberates through your ship. \"Warning,\" the" ..
    " ship's computer announces, \"near miss by energy beam weapon.\" You hold" ..
    " on, hoping it doesn't get any closer, knowing there's not anything you" ..
    " can do with so little fuel." ..
    " \r\n\tYour ship shudders for a moment as the rockets suddenly" ..
    " fire. The rockets stop, and a few moments later a loud" ..
    " thud resounds throughout the ship. \"Docking completed,\"" ..
    " the tinny computer voice announces.")
    startroom.isdocked = true
    incscore(5)
    setfuse(stationShake, rand(4)+3, nil)
end
 
function stopCycle(parm)

    if ((not stationAir.iscycled) and cycleButton.armState == 1) then
        if (Me.location == stationAir) then
            print("\r\n\tA mechanical voice announces, \"The airlock cycle" ..
            " is no longer armed. Press the cycle button to" ..
           "re-initiate the airlock cycle.\"")
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

function suffowarn2(parm)
    if ( Me.location.isvac) then
       print("\r\n\tYou're getting quite lightheaded from lack" ..
        " of oxygen. You should strongly consider moving" ..
        " back to an air-rich environment immediately. ")
        setfuse(suffodo, 3 , nil)
    end
end

function airLight(parm)
    if (Me.location.isvac) then 
        print("\n\tA red indicat_or light in your helmet depicting an empty air tank is flashing insistently")
        game.suffoCount = game.suffoCount + 1
        if (game.su2ffoCount > 4 ) then
            print(", accompanied by an ear-piercing alarm klaxon. ")
        else 
            print(". ")
        end
    else 
        remdaemon( airLight, nil )
    end
end

function tram2Planet (parm)
    local l
    l = tramShip.launchState
    if (l == 2) then
        print("The retros fire gently. The tram slowly loses its orbital" ..
        " velocity, and starts to fall toward the planet." ..
        " \r\n\tThrough your vie   wport, you see a giant beam of energy from" ..
        " he planet, which seems to be aimed directly at your tram! After" ..
        " a moment, though, you realize that the beam is just missing your" ..
        " .  It is, however, directly hitting the space station." ..
        " A huge shower of sparks and bits of material fly away" ..
        " from the station. Suddenly, the entire station explodes in" ..
        " a tremendous but strangely silent fireball. After a few moments" ..
        " you hear a tapping sound as chunks of material from the explosion" ..
        " hit your tram. ")
    elseif (l == 3) then
        local msg = "Through the viewscreen you can see nothing more than the bright red of incandescing air as the tram plunges" ..
 " into the atmosphere. As the outer shell of the tram" ..
 " heats up, the turbulence increases, shaking the tram" ..
 " like a demented baby's rattle."
        print(msg)
        if (Me.location.fastenitem) then
            print("Luckily you are securely buckeled in, and" ..
 " ride out this part of the trip feeling only" ..
 " slightly nauseous.")
        else
            print("Unfortunately, you've neglected to attach yourself" ..
 " in any way to the tumbling ship, and are mercilessly" ..
 " thrown about the interior of the tiny tram. Needless" ..
 " to say, everything you carried aboard is bouncing" ..
 " wildly off of the walls.")
            dropAll( Me )
    end
        print("The tram starts firing its landing rockets. ")
    elseif (l == 5) then
        print("The tram gently settles onto the ground. The motors slowly power down. ")
    elseif (l == 6) then
        local msg = "The hatch slides open. Outside, you hear giggling. You" ..
 " peer cautiously through the door. You see a man standing on" ..
 " the launch pad, looking up at the sky, rubbing his hands" ..
 " together, cackling with glee. Overhead, a meteor shower" ..
 " of debris from the destroyed space station is slowly" ..
 " streaming through the upper atmosphere." ..
 " \r\n\t\"She can't stop me now,\" the man cackles to himself." ..
 " \"Lord Pinback, Emperor of the Galaxy!\" He picks up a power" ..
 " supply that was sitting on the ground next to him, and wanders" ..
 " off into the distance."
        print(msg)
        tramHatch.isopen = true
        remdaemon(tram2Planet, nil)
        game.sleepList[#global.sleepList] = tramShip
        incscore(10)
    end
    tramShip.launchState = l + 1
end
 
function tram2Hell(parm)
    local s
    
    s = tramShip.launchState
    if (s < 105) then
        print("The tram continues to drift into space. ")
    else
        print("The tram inexplicably decides to fire its engines" ..
  " at full power, and turns over all resources" ..
  " including life support, to increasing the engine" ..
  " strength. This is a safety \"bug\" that consumer" ..
  " advocates have noted in the TripMaster 2000(tm)," ..
  " and frequently occurs when the tram is fed invalid" ..
  " destination coordinates. The oxygen runs out quite" ..
  " rapidly under these conditions.")
        remdaemon( tram2Hell, nil )
    end
    tramShip.launchState = s + 1
end

function tram2Station(parm)
    local s
    s = tramShip.launchState
    if (s == 9) then
        print("The rockets cut off. The tram leaves the last remnants" ..
        " of atmosphere. ")
    elseif (s == 10) then 
        print("The space station approaches in the distance. The retros" ..
        "fire. ")
    elseif (s == 11) then
        print("The Tram is slowly drifting toward the station. ")
    elseif (s == 12) then
        tramShip.launchState = 0
        tramHatch.isopen = true
        print("The tram approaches one of the station's docking ports," ..
        " and finally comes up against it, lurching to a halt." ..
        " You hear the motors power down. After a few moments, the" ..
        " hatch slides open. ")
        if (not tramShip.hasScored) then
            tramShip.hasScored = true
            incscore(3)
        end
        remdaemon(tram2Station, nil)
    end 
    if (s ~= 12) then
        tramShip.launchState = s + 1
    end
end

function shipDie(parm)
    if (
        ((Me.location == startroom) or (Me.location == startChair))
        and
        not (startroom.isdocked)) then
        print("\bYour ship finally runs out of air. You run out soon" ..
        " thereafter. ")
        die()  
    end
end

function distressCall(parm)
    print("Your computer's tinny voice announces, \"Now receiving" ..
    " incoming message.\" A three dimensional image of a woman appears." ..
    " She is striking, but she looks very tired and distraught." ..
    " \"Hello,\" she says, \"I'm receiving your distress signal." ..
    " I'm on Space Station K-7, which is in orbit of the planet nearest" ..
    " your position.  Do you have enough fuel to get here?\" Suddenly" ..
    " the room behind her seems to shake, and the picture dissolves" ..
    " into static. After a moment, the picture returns; the woman is" ..
    "nervously typing something on a control panel. \"Look,\" she says," ..
    "\"I probably won't be here when you get here. You should try to make" ..
    " your repairs and leave as soon as you can. We're --\" the picture" ..
    " dissolves into static again, and doesn't return for several" ..
    " moments. \"-- my autonav code now. Are you receiving?\" The picture" ..
    " breaks up into static. The computer voice comes back on. \"Receiving" ..
    " autonav signal on bearing 5381. Video channel closed.\"")
    autonavButton.isready = true
end

function hasMonster(rm)
    if (fmonster1.location == rm) then return monster1 end
    if (monster2.location == rm) then return monster2 end
    return nil
end

function isTubeDest(r)
    if ( r.outTubeX == shuttle.xcoord and r.outTubeY == shuttle.ycoord and r.outTubeZ == shuttle.zcoord ) then
        shuttle.tubeDest = r
        return true
    else 
        return nil
    end
end

--[[
function shuttleDaemon(parm)
    local x, y, thereYet, i, cnt, l, found

    if (shuttle.outRem > 1) then    -- outbound from station
        if (Me.location == shuttle ) then
            print("\bThe shuttle speeds down the tube. ")
            shuttle.outRem = shuttle.outRem - 1
    elseif (shuttle.outRem = 1) then-- emerging into central
        shuttle.outRem = 0
        shuttle.moveInto(centralHub)
        if ( Me.location == shuttle ) then
            print("The shuttle emerges into a gigantic hub," ..
            " where dozens of tubes come together. The basically" ..
            " cubic enclosure, hundreds of meters on a side, has walls" ..
            " to the north, east, south, and west, and each wall has" ..
            " a three-by-three grid of tubes entering it. ")
            end
    elseif (shuttle.inRem > 1) then -- inbound to station
        if (Me.location == shuttle) then
            print("\bThe shuttle speeds down the tube. ")
        shuttle.inRem = shuttle.inRem - 1
        end
    elseif (shuttle.inRem == 1) then -- arriving at station
        shuttle.inRem = 0

        if (shuttle.tubeDest == tubeRubble) then
            setTubeNose( tubeRubble ) then
            if (Me.location == shuttle) then
                print("\bThe shuttle slows to a stop. You notice that the tube" ..
                " ahead is blocked by a wall of rubble. The shuttle thinks a" ..
                " few moments, then turns around and speeds back the way it" ..
                " came. ")
            end
        else
            shuttle.moveInto( shuttle.tubeDest )
            shuttle.isActive = nil
            remFromList(game.sleepList, shuttle)
            remdaemon( shuttleDaemon, nil)
            if (Me.location == shuttle) then
                print("\bThe shuttle emerges into a depot and comes to a stop.")
                if (not canopy.isblown) then 
                    print(" The canopy opens.") 
                end
                shuttle.location.doVerb("enter", Me, nil)
            end
            elseif (Me.location == shuttle.location) then
                print("\bA shuttle emerges from the tunnel and comes to a stop. ")

            if ( shuttle.location = reactorDepot )
            {
                /*
                 *   Check for zeenite
                 */
                local c;

                c := zeenite;
                while ( c )
                {
                    if ( c = reactorDepot )
                    {
                        if ( Me.location = shuttle )
                        {
                            "The zeenite starts to grow terribly hot, and
                            to bubble and emit noxious fumes.  You realize
                            to your horror that it's about to explode, and
                            try to discard it, but it's too late. The
                            zeenite explodes in one of the more spectacular
                            fireballs that you've ever held at arm's length. ";
                            die();
                            abort;
                        }
                        else
                        {
                            "A distant explosion rumbles through the base.
                            It sounded like a huge blast. ";
                            zeenite.timer := 0;
                            incscore( 30 );
                            setdaemon( bombDaemon, nil );
                        }
                    }
                    c := c.location;
                }
            }
        }
    }
    else                      // in central clearinghouse
    {
        if ( Me.location = shuttle )
            "\bThe shuttle speeds through the cavernous hub, ";

        thereYet := nil;      // we're not there yet by default

        if ( shuttle.autoDest )    // if on autopilot, steer
        {

            if ( shuttle.zcoord = shuttle.autoDest.outTubeZ )
            {
                /*
                 *   figure out if we're there yet
                 */
                x := shuttle.noseX;
                y := shuttle.noseY;

                // figure out if we're there by going straight ahead
                if ( shuttle.xcoord+x = shuttle.autoDest.outTubeX and
                 shuttle.ycoord+y = shuttle.autoDest.outTubeY )
                {
                    thereYet := true;
                    joystick.ycoord := joystick.xcoord := 0;
                }

                // figure out if we're there by banking right
                if (( y=1 and shuttle.ycoord=shuttle.autoDest.outTubeY
                  and shuttle.xcoord+1 = shuttle.autoDest.outTubeX ) or
                 ( y=-1 and shuttle.ycoord=shuttle.autoDest.outTubeY
                  and shuttle.xcoord-1 = shuttle.autoDest.outTubeX ) or
                 ( x=1 and shuttle.xcoord=shuttle.autoDest.outTubeX
                  and shuttle.ycoord-1 = shuttle.autoDest.outTubeY ) or
                 ( x=-1 and shuttle.xcoord=shuttle.autoDest.outTubeX
                  and shuttle.ycoord+1 = shuttle.autoDest.outTubeY ))
                {
                    thereYet := true;
                    joystick.ycoord := 0;
                    joystick.xcoord := 1;
                }
            }

            if ( not thereYet )
            {
                /*
                 *   We're not there - maneuver automatically
                 */
                if ( shuttle.zcoord > shuttle.autoDest.outTubeZ )
                    joystick.ycoord := 1;
                else if ( shuttle.zcoord < shuttle.autoDest.outTubeZ )
                    joystick.ycoord := -1;
                else joystick.ycoord := 0;

                x := shuttle.xcoord;
                y := shuttle.ycoord;

                if ( x=1 )
                {
                    if ( y=1 ) joystick.xcoord := shuttle.noseY;
                    else joystick.xcoord := shuttle.noseX;
                }
                else if ( x=2 ) joystick.xcoord := ( 2-y )*shuttle.noseY;
                else
                {
                    if ( y=3 ) joystick.xcoord := -shuttle.noseY;
                    else joystick.xcoord := -shuttle.noseX;
                }
            }
        }

        /*
         *   Now look at joystick and maneuver accordingly
         */
        if ( joystick.xcoord=1 )
        {
            if ( Me.location = shuttle ) "banking gracefully to the right, ";
            if ( shuttle.noseX )
            {
                shuttle.noseY := -shuttle.noseX;
                shuttle.noseX := 0;
            }
            else
            {
                shuttle.noseX := shuttle.noseY;
                shuttle.noseY := 0;
            }
        }
        else if ( joystick.xcoord = -1 )
        {
            if ( Me.location = shuttle ) "banking gently to the left, ";
            if ( shuttle.noseX )
            {
                shuttle.noseY := shuttle.noseX;
                shuttle.noseX := 0;
            }
            else
            {
                shuttle.noseX := -shuttle.noseY;
                shuttle.noseY := 0;
            }
        }

        if ( joystick.ycoord=1 and shuttle.zcoord>1 )
        {
            if ( Me.location = shuttle ) "descending a level, ";
            shuttle.zcoord := shuttle.zcoord - 1;
        }
        else if ( joystick.ycoord=-1 and shuttle.zcoord<3 )
        {
            if ( Me.location = shuttle ) "ascending a level, ";
            shuttle.zcoord := shuttle.zcoord + 1;
        }

        if ( Me.location = shuttle ) "and is heading toward the ";

        /*
         *   We now need to say which hole we're pointing at.
         *   To make this possible, transform to wall coordinates.
         *   Wall Y (vertical) is shuttle always Z (vertical);
         *   wall X depends on the direction we're going:
         *    north ==> shuttle X
         *    south ==> 4 - (shuttle X) (invert coordinates)
         *    east  ==> 4 - (shuttle Y)
         *    west  ==> shuttle Y
         */
        y := shuttle.zcoord;           // y is easy, but...
        if ( shuttle.noseX=1 )         // travelling east
        {
            x := 4-shuttle.ycoord;     // so invert shuttle's Y
            if ( Me.location = shuttle ) "east";
        }
        else if ( shuttle.noseX=-1 )   // travelling west
        {
            x := shuttle.ycoord;       // so use shuttle's Y
            if ( Me.location = shuttle ) "west";
        }
        else if ( shuttle.noseY=1 )    // travelling north
        {
            x := shuttle.xcoord;       // use shuttle's X
            if ( Me.location = shuttle ) "north";
        }
        else                           // travelling south
        {
            x := 4-shuttle.xcoord;     // invert shuttle's X
            if ( Me.location = shuttle ) "south";
        }
        if ( Me.location = shuttle )
        {
            " wall's ";
            if ( x=2 and y=2 ) "center";
            else
            {
                if ( x=1 ) "left";
                else if ( x=2 ) "center";
                else "right";
                " ";
                if ( y=3 ) "top";
                else if ( y=2 ) "center";
                else "bottom";
            }
            " hole. ";
        }

        shuttle.xcoord := shuttle.xcoord + shuttle.noseX;
        shuttle.ycoord := shuttle.ycoord + shuttle.noseY;

        if ( Me.location = airvent2 )
        {
            "\bIn the hub below, you can see a shuttle maneuvering.  It
            is currently ";
            if ( shuttle.xcoord = 1 and shuttle.ycoord = 3 )
                "directly below";
            else if ( shuttle.xcoord = 1 )
            {
                if ( shuttle.ycoord = 2 ) "just"; else "somewhat";
                " south of";
            }
            else if ( shuttle.ycoord = 3 )
            {
                if ( shuttle.xcoord = 2 ) "just"; else "somewhat";
                " east of";
            }
            else "southeast of";
            " you. ";
        }

        /*
         *   Figure out if we're in a hole now - if so, go to tube mode
         */
        if ( shuttle.xcoord<1 or shuttle.xcoord>3 or
         shuttle.ycoord<1 or shuttle.ycoord>3 )
        {
            if ( Me.location = shuttle )
                "It plunges into the hole with a rush of air. ";
            shuttle.moveInto( tubeRoom );

            /*
             *   We need to scan the list of depot rooms (those with
             *   a true isDepot property) to find out which one we're
             *   heading towards.  This list should be set up at init
             *   time.
             */
            l := global.depotList;
            cnt := length( l );
            i := 1;
            found := nil;
            while ( i <= cnt )
            {
                if (isTubeDest( l[i] ))
                {
                    found := true;
                    break;
                }
                i := i + 1;
            }
            if ( not found )
            {
                shuttle.tubeDest := tubeRubble;
                shuttle.inRem := 3;
                tubeRubble.outTubeX := shuttle.xcoord;
                tubeRubble.outTubeY := shuttle.ycoord;
                tubeRubble.outTubeZ := shuttle.zcoord;
            }
            shuttle.inRem := shuttle.tubeDest.tubeLength;
        }
    }
}
setTubeNose: function( r )
{
    local x, y, nx, ny;

    x := r.outTubeX;
    y := r.outTubeY;

    if ( x=0 )      { nx :=  1; ny :=  0; }
    else if ( x=4 ) { nx := -1; ny :=  0; }
    else if ( y=0 ) { nx :=  0; ny :=  1; }
    else            { nx :=  0; ny := -1; }

    shuttle.noseX := nx;
    shuttle.noseY := ny;

    shuttle.xcoord := x + nx;
    shuttle.ycoord := y + ny;
    shuttle.zcoord := r.outTubeZ;

    shuttle.outRem := r.tubeLength;

    shuttle.moveInto( tubeRoom );
}
vacDaemon: function( parm )
{
    local newRoom, exitDir, moveL, meLoc;

    meLoc := Me.location;
    while ( meLoc.location ) meLoc := meLoc.location;

    /*
     *   This function moves the vacRobot each turn that
     *   it's activated, and displays a message if the player
     *   is in the room that just got entered or left.
     */
    if ( not vacRobot.isActive ) return;

    vacRobot.turnsLeft := vacRobot.turnsLeft - 1;

    if ( vacRobot.turnsLeft = 0 )
    {
        /*
         *   He moves
         */
        moveL := vacRobot.moveList;
        exitDir := car( moveL );
        moveL := cdr( moveL ) + exitDir;
        newRoom := car( moveL );
        moveL := cdr( moveL ) + newRoom;
        vacRobot.moveList := moveL;

        vacRobot.turnsLeft := 3;

        if ( meLoc = vacRobot.location )
        {
            "\bThe robot dashes out of the room, heading ";
            say( exitDir ); " to continue its chores. ";
        }
        vacRobot.moveInto( newRoom );
        if ( meLoc = newRoom )
        {
            "\bA large robot enters the room, and starts
            noisily vacuuming. ";
        }
    }
    else if ( meLoc = vacRobot.location )
        "\bA large robot busily vacuums the room. ";
}
gauntletRobotFuse: function( parm )
{
    local meLoc;

    meLoc := Me.location;
    while ( meLoc.location ) meLoc := meLoc.location;

    gauntlet1.isActive := true;
    gauntlet1.isPowerless := nil;

    if ( meLoc = gauntlet1 )
    {
        "\bA terrible 10-Hertz hum resounds through the corridoor,
        and you see each weapon light up and come to life.
        The weapons all swing around and point directly at you.
        You try to run, but before you can get anywhere, the
        weapons unleash a volley of fire on you. ";
        die();
    }
    else if ( meLoc = gauntletEntry or meLoc = gauntletDepot )
    {
        "\bFrom the ";
        if ( meLoc = gauntletEntry ) "east"; else "west";
        " you hear the sound of huge power supplies coming to life.
        Presumably, the weapons in the hallway have regained
        their charge. ";
    }
}
bombDaemon: function( parm )
{
    local t;

    t := ( zeenite.timer := zeenite.timer + 1 );
    if ( t = 2 )
        "\bDistant explosions from the direction of the
        reactor rumble through the base. ";
    else if ( t = 4 )
        "\bA series of huge explosions rumbles through the base. Dust
        falls from above as the walls seem to buckle. ";
    else if ( t = 6 )
    {
        remdaemon( bombDaemon, nil );
        "\bA huge fireball rises into the sky as the reactor
        is consumed in flame. Terrible explosions rip through
        the base, levelling the entire complex.\b";
        if ( Me.location = escapeShip and escapeShip.isActive )
            "It's fortunate that you escaped in time. ";
        else
        {
            "It's a shame you're still here. ";
            die();
        }
    }
}
escapeDaemon: function( parm )
{
    local t;

    t := ( escapeShip.timer := escapeShip.timer + 1 );
    if ( t > 1 and t < 4 )
        "\bThe ship continues to rise through the atmosphere. ";
    else if ( t < 7 )
        "\bThe ship continues to ascend into orbit. ";
    else
    {
        "\bA previously unseen communications panel attracts your
        attention. \"Attention, unidentified ship,\" a voice says
        through a speaker, \"are you in need of assistance?\"
        \n\tYou find the transmitter, and explain your situation.
        You quickly learn that the calling ship is a Galactic
        Spaceway Patrol cruiser that was in the area responding
        to someone else's distress signal.
        \n\tThe cruiser takes you on board. As you're departing your
        small shuttle, the commander comes over to you. You cheerfully
        greet him, thinking he has come to congratulate you for shutting
        down the dangerous laser base. \"Do you know why we pulled you
        over?\" he asks, then proceeds to request your pilot's license
        and proof of insurance. \"You were operating an unspaceworthy
        vessel, young man.  I'm afraid you'll have to come downtown
        with us.\"
        \n\tHe escorts you to the ship's brig, where you are surprised
        to see Sigourney, the woman who answered your distress signal.
        She explains that she never made it down to the planet, since
        her ship was disabled by a near miss from the laser. \"So the
        GSP answered my distress signal and came and picked me up, and
        then they gave me this!\" She shows you a citation for operating
        an unspaceworthy vessel, just like the one you received. \"Oh,
        well, I suppose it beats spinning uncontrollably through space
        until either your oxygen runs out or you burn up entering the
        atmosphere of some anonymous planet.\"
        \n\tAt that, the commander turns and walks away,
        laughing maniacally, as the
        brig doors slam shut on another chapter in your life.\b";

        incscore( 15 );
        scoreRank();
        terminate();
        quit();
    }
}
exitOptions: function
{
    "\nYou can start over, restore from a saved game, quit,
    or try to undo the last command. ";
    while ( true )
    {
        local resp;
	
        "Please type RESTART, RESTORE, QUIT, or UNDO >";

        resp := upper( input() );
        if ( resp = 'RESTART' )
        {
            setscore( 0, 0 );
            restart();
        }
        else if ( resp = 'QUIT' )
        {
            terminate();
            quit();
            abort;
        }
        else if ( resp = 'RESTORE' )
        {
            resp := askfile( 'File to restore' );
            if ( resp = nil )
                "Restore failed.";
            else if ( restore( resp ))
		"Restore failed.";
            else
            {
                setscore( global.score, global.turnsofar );
                "Restored. ";
                abort;
            }
        }
	else if (resp = 'UNDO')
	{
	    if (undo())
	    {
		"(Undoing one command)\b";
		Me.location.lookAround(true);
	        setscore(global.score, global.turnsofar);
		abort;
	    }
	    else
		"Sorry, no undo information is available.";
	}
    }
}
goToSleep: function
{
    local notifyList, i, cnt, dreamOk;

    /*
     *   Send a "sleeping" message to everyone in the sleeping notification
     *   list.  It is legal for objects to remove themselves from this list
     *   in the "sleeping" method.  A "true" return from "sleeping" means
     *   that the player wakes up immediately, skipping dreams.
     */
    notifyList := global.sleepList;
    i := 1;
    cnt := length( notifyList );
    dreamOk := true;
    while ( i <= cnt )
    {
        if ( notifyList[i].sleeping ) dreamOk := nil;
        i := i + 1;
    }

    if ( dreamOk )
    {
        global.awakeTime := 0;  // reset wake-up time

        /*
         *   Is there a real dream to run?  If so, run it.  If not, run a
         *   random dream.
         */
        if (car( global.dreamList ))
        {
            global.dreamList[1].runDream;
            global.dreamList := cdr( global.dreamList );
        }
        else if (car( global.randomDreamList ))
        {
            local d;

            d := global.randomDreamList[rand(length( global.randomDreamList ))];
            d.runDream;
        }
        else
        {
            "\b* * * * *
            \bYou wake up some time later, refreshed. ";
        }
    }

    // 2/3 of a meal period elapses in a good night's sleep
//    global.lastMealTime := global.lastMealTime + 2*global.eatTime/3;
}
caveDaemon: function( parm )
{
    local t;

    t := global.cavetime + 1;

    if ( t = 6 )
    {
        "\bYou hear a loud rumbling in the distance.  It seems to
        be coming your way. ";
    }
    else if ( t = 7 )
    {
        if ( Me.location.iscaveledge )
        {
            "\bThe distant rumbling becomes a thundering torrent of
            water flowing through the cave directly below. Fortunately,
            you are on high ground, and avoid the flood.\n";
        }
        else if ( Me.location = caveLake )
	{
	    "\bThe distant rumbling becomes a wall of water washing into
	    the lakebed. The water rises for several moments, then the
	    flood subsides, and the lakebed once again dries up.\n";
	}
	else
        {
            "\bThe distant rumbling becomes a wall of water washing into
            the cave. You scramble to avoid the flood, but it's far faster
            than you are. The water washes you for a great distance, then
            finally subsides, leaving you to dry off.\n";
            Me.travelTo( caveLake );
        }
        t := 0;
    }

    global.cavetime := t;
}

numObj: basicNumObj;
/*
object              // when a number is used in a player command,
    value = 0               //  this is set to its value
    verDoTypeOn( actor, io ) = {}
    doTypeOn( actor, dobj ) = { "\"Tap, tap, tap, tap...\" "; }
    verIoTurnTo( actor ) = {}
    ioTurnTo( actor, dobj ) = { dobj.doTurnTo( actor, self ); }
    verIoMoveTo( actor ) = {}
    ioMoveTo( actor, dobj ) = { dobj.doMoveTo( actor, self ); }
    sdesc = "that"
    adesc = "that"
    thedesc = "that"
;
*/
strObj: basicStrObj;
/*
 object              // when a string is used in a player command,
    value = ''              //  this is set to its value
    sdesc = "that"
    adesc = "that"
    thedesc = "that"
    verDoTypeOn( actor, io ) = {}
    doTypeOn( actor, io ) = { "\"Tap, tap, tap, tap...\" "; }
    doSave( actor ) =
    {
        if (save( self.value ))
            "Save failed. ";
        else
            "Saved. ";
        abort;
    }
    doRestore( actor ) =
    {
        if (restore( self.value ))
            "Restore failed. ";
        else
        {
            setscore( global.score, global.turnsofar );
            "Restored. ";
        }
        abort;
    }
    verDoScript( actor ) = {}
    doScript( actor ) =
    {
        logging( self.value );
        "Writing script to "; say( self.value ); ".\n";
        abort;
    }
    verDoSay( actor ) = {}
    doSay( actor ) =
    {
        "Okay, \""; strObj.value; "\".";
    }
;
*/
global: object
    turnsofar = 0
    score = 0
    maxscore = 200
    verbose = nil
    awakeTime = 790
    sleepTime = 800
    lastMealTime = 393
    eatTime = 400
    planetCoord = 1701
    stationCoord = 69814
    dreamList = []          // list of important dreams ("dream" objects)
    randomDreamList = []    // list of random dreams ("dream" objects)
    sleepList = []          // list of objects to notify (with "sleeping"
                            //   messages) when player sleeps
;
Me: basicMe
;
version: object
    sdesc = "Deep Space Drifter\nRelease << self.vsnnum >>\n"
    vsnnum = '1.0'
;
vacRobot: robotItem
    location = stationMain
    moveList =
    [
        'west' stationTel
        'east' stationMain
        'southwest' stationBed2
        'east' stationLav
        'east' stationBed1
        'north' stationMain
        'east' stationDock
        'west' stationMain
        'north' stationKitchen
        'south' stationMain
    ]
    turnsLeft = 3
    ldesc =
    {
        "It's a DroidMaster 2000(tm), the top of the line
        model. It sports a small slot, which ";
        if (car( vacRobotSlot.contents ))
        {
            "contains "; car( vacRobotSlot.contents ).adesc; ". ";
        }
        else "is empty. ";
        "It has the likeness of a red and white checked
        apron painted on it. ";
        if ( vacuumCleaner.location = self.location )
            "It's carrying a vacuum cleaner. ";
    }
    actorDesc =
    {
        "A large domestic robot is ";
        if ( self.isActive )
            "dashing about the room, busily vacuuming and
            tidying up. ";
        else
            "sitting in the corner, apparently switched off. ";
    }
    verGrab( item ) =
    {
        if ( self.isActive )
        {
            "The robot is dashing around far too quickly for
            you to be able to take "; item.thedesc; ". ";
        }
    }
    sleeping =
    {
        local a, b, c;
	
	if ( self.isActive )
	{
            a := self.moveList;
            b := a[1];
            c := a[2];
            a := cdr(cdr( a ));
            self.moveList := a + b + c;
            self.moveInto( c );
            self.turnsLeft := 3;
	}
        return( nil );
    }
;
startBelt: seatbeltitem
    location = startChair
    noun = ['belt' 'seatbelt']
    adjective = ['seat']
;
startChair: chairitem
    location = startroom
    noun = ['seat' 'chair']
    adjective = ['pilot\'s' 'pilot' 'flight']
    reachable = { return( self.location.contents - shipHatch ); }
    sdesc = "pilot's seat"
    ldesc =
    {
        "It's looks like an ordinary, albeit well worn, flight
        chair, complete with seatbelt (which is ";
        if ( startBelt.isfastened )
            "fastened";
        else
            "unfastened";
        "). ";
    }
;
swampDream: dream
    runDream =
    {
        self.setupDream;
        "\bYou are in a strange swamp. A plant with
        gaping jaws is here, holding an odd balloon
        creature in its maw.
        \n\tYou notice the plant has a red spot near
        its base. You're not sure why, but you feel
        compelled to walk over to the plant and touch
        the spot. As you do, the plant seems to be
        tickled by it, and in the foliage equivalent
        of a sneeze, shoots the balloon creature high
        into the air to the north.\b";
        Me.travelTo( dreamSwamp1 );
    }
;
xeniteDream: dream
    runDream =
    {
        self.setupDream;
        "\bIt is a sunny high school day. Your high energy
        physics teacher has just told you something about how
        the accelerator is emitting M-rays of a highly unstable
        nature. You remember something about Xenite and M-rays...\b";
        Me.travelTo( dreamLab );
    }
;
startroom: room
/*
 *  This is the spaceship interior, where the player starts.
 */
    isdocked = nil
    west =
    {
        if ( shipHatch.isopen )
            return( airLock2 );
        else
        {
            "The hatch is closed. ";
            setit( shipHatch );
            return( nil );
        }
    }
    sdesc = "Spaceship"
    first_view = true
    ldesc =
    {
        if ( self.first_view )
        {
            self.first_view := nil;
            "You are securely belted into the pilot's seat of";
        }
        else if ( Me.location = startChair )
        {
            if ( Me.location.fastenitem )
            {
                "You are securely belted into the pilot's seat
                of";
            }
            else
            {
                "You are seated comfortably in the pilot's seat
                of";
            }
        }
        else
        {
            "You are in the cockpit of your trusty spaceship.
             There is a pilot's seat here which dominates this small
             enclosure.  A console occupies the north wall, and there
             is a hatch to the west, which is ";
             if ( shipHatch.isopen ) "open"; else "closed"; ". ";
             return;
        }
        " your trusty spaceship. A console occupies
        the north wall. The hatch to the west is ";
        if ( shipHatch.isopen )
            "open";
        else
            "closed";
        ". ";
    }
;
stationAir: room
    sdesc = "Airlock"
    ldesc =
    {
        "You are in an airlock. ";
        if ( self.iscycled )
            "The door to the east is open to space,
            and the door to the west is closed. ";
        else
            "The door to the east is closed, and an
            open door to the west leads into the station. ";
        "A large red button on the wall reads \"Cycle\". ";
    }
    iscycled = nil
    east =
    {
        if ( self.iscycled ) return( stationEva1 );
        "The door is closed. ";
        return( nil );
    }
    west =
    {
        if ( not self.iscycled ) return( stationAir1 );
        "The door is closed. ";
        return( nil );
    }
;
cycleButton: buttonitem
    location = stationAir
    sdesc = "red button"
    ldesc =
    {
        "The button is large and red, and is labelled with
        the word \"Cycle\". ";
    }
    adjective = ['red' 'cycle']
    armState = 0
    doPush( actor ) =
    {
        if ( not stationAir.iscycled )
        {
            if ( self.armState = 0 )
            {
                self.armState := 1;
                "You hear a mechanical voice state,
                \"Warning: airlock cycle ready. Check
                your suit and press cycle button again
                when ready to depressurize.\"";
                setfuse( stopCycle, 3, nil );
            }
            else if ( self.armState = 1 )
            {
                self.armState := 0;
                "The door to the west slides shut, and
                you hear a rush of air. Soon the sound
                fades, and then is gone altogether, and
                you realize that the chamber is now a
                high vacuum.  The east door slides open. ";
                if ( not spacesuit.isworn )
                {
                    "Unfortunately, you are not wearing any
                    protective gear. Explosive decompression
                    is never a pretty sight, so you'll forgive
                    me if I don't go into details here. ";
                    die();
                }
                else
                {
                    stationAir.iscycled := true;
                    stationAir.isvac := true;
                    if ( suitTank.location <> spacesuit or
                      not suitTank.isfull )
                    {
                        setfuse( suffowarn, 2, nil );
                        setdaemon( airLight, nil );
                        global.suffoCount := 0;
                    }
                    global.sleepList := global.sleepList + self;
                }
            }
        }
        else
        {
            "The outer door slides shut silently.  After a few
            moments, you hear the muffled sound of air rushing
            through a valve; the sound grows louder as the pressure
            in the chamber increases. Eventually, the chamber reaches
            normal pressure, and the west door slides open. ";
            stationAir.iscycled := nil;
            stationAir.isvac := nil;
            global.sleepList := global.sleepList - self;
            if (( not self.hasScored ) and
             ( fuse.location = tramCompartment ))
            {
                self.hasScored := true;
                incscore( 18 );
            }
        }
    }
    sleeping =
    {
        "You are awakened by an ear-piercing alarm klaxon sounding
        within your helmet. You realize that your air tank must be
        nearly empty by now. ";
        if ( suitTank.location = spacesuit and suitTank.isfull )
        {
            suitTank.isfull := nil;
            setfuse( suffowarn, 2 );
            setdaemon( airLight, nil );
        }
        global.sleepList := global.sleepList - self;
        global.suffoCount := 5;
        return( true );
    }
;
suitTank: item
    weight = 3
    bulk = 3
    location = spacesuit
    noun = ['tank' 'valve' 'airmaster']
    adjective = ['air']
    sdesc = "air tank"
    adesc = "an air tank"
    ldesc =
    {
        "It's an AirMaster 2000 (tm), the top of the line
        model. It looks large enough to hold an hour's worth
        of air. A small gauge on the tank's valve reads ";
        if ( self.isfull )
            "full";
        else
            "empty";
        ". ";
        if ( self.attachment )
            "The valve is connected to an air hose. ";
    }
    verDoAttachTo( actor, iobj ) =
    {
        if ( self.attachment )
        {
            "You'll have to detach "; self.thedesc; " from ";
            self.attachment.thedesc; " first. ";
        }
        else if ( self.location = spacesuit )
        {
            "It's already attached to the spacesuit! ";
        }
    }
    doAttachTo( actor, iobj ) =
    {
        if ( iobj = airhose )
        {
            self.attachment := airhose;
            airhose.attachment := self;
           "The hose fits snugly over the valve. ";
        }
        else if ( iobj = spacesuit )
        {
            "With some difficulty, you manage to attach the
            tank to the spacesuit. ";
            self.moveInto( spacesuit );
        }
        else
        {
            "I don't know how to do that. ";
        }
    }
    verIoAttachTo( actor ) =
    {
        self.verDoAttachTo( actor, nil );
    }
    ioAttachTo( actor, dobj ) =
    {
        if ( dobj = airhose ) dobj.doAttachTo( actor, self );
        else pass ioAttachTo;
    }
    verIoPutOn( actor ) =
    {
        self.verIoAttachTo( actor );
    }
    ioPutOn( actor, dobj ) =
    {
        self.ioAttachTo( actor, dobj );
    }
    verIoTakeOff( actor ) = { self.verIoDetachFrom( actor ); }
    ioTakeOff( actor, dobj ) = { self.ioDetachFrom( actor, dobj ); }
    verIoDetachFrom( actor ) =
    {
        if ( self.attachment=nil ) "It's not attached to that! ";
    }
    ioDetachFrom( actor, dobj ) =
    {
        dobj.doDetachFrom( actor, self );
    }
    verDoDetachFrom( actor, io ) =
    {
        if ( self.attachment <> io ) "It's not attached to that! ";
    }
    doDetachFrom( actor, io ) =
    {
        self.attachment.attachment := nil;
        self.attachment := nil;
        "Done. ";
    }
    verDoDetach( actor ) =
    {
        if ( self.attachment=nil ) "It's not attached to anything! ";
    }
    doDetach( actor ) =
    {
        self.doDetachFrom( actor, self.attachment );
    }
;
spacesuit: clothingItem, qcontainer
    weight = 5
    bulk = 8
    sdesc = "spacesuit"
    ldesc =
    {
        "The spacesuit is a ComfortMaster 2000 (tm), the top
        of the line model. It sports a headlamp (which ";
        if (car( suitSocket.contents ))
        {
            "contains a ";
            if ( self.islighton and goodbulb.location = suitSocket )
                "lit ";
            "GlowMaster 2000 (tm) bulb, the top of the line model";
        }
        else
            "has been removed, leaving an empty socket";
        "), ";
        if ( suitTank.location = self )
            "an oxygen tank for your breathing comfort, ";
        "and a white button on the left arm. ";
    }
    noun = ['suit' 'spacesuit' 'comfortmaster']
    adjective = ['space']
    doWear( actor ) =
    {
        /* make sure the actor is directly carrying me */
        if (self.location != actor)
        {
            /* try taking it */
            "(First taking <<self.thedesc>>)\n";
            if (execCommand(actor, takeVerb, self) != 0)
                exit;

            /* make sure they actually were able to take me */
            if (self.location != actor)
                exit;
        }

        "With some difficulty, you manage to get into
        the spacesuit. It never ceases to amaze that
        in today's high tech world, they can
        make a decaffeinated coffee that tastes good,
        but they still can't make a spacesuit that
        fits. ";
        self.isworn := true;
    }
    doUnwear( actor ) =
    {
        if ( actor.location.isvac )
        {
            "I simply do what you tell me, even when it will
            obviously result in your demise, as does removing
            your space suit in open space. ";
            die();
        }
        else
        {
            "You manage to get out of the bulky ComforMaster 2000(tm). ";
            self.isworn := nil;
        }
    }
    location = stationAir1
    verIoPutIn( actor ) = {}
    verIoAttachTo( actor ) = {}
    ioPutIn( actor, dobj ) =
    {
        if ( dobj <> suitTank )
        {
            "I don't know how to attach that to the spacesuit. ";
        }
        else if ( dobj.location = self )
        {
            "It's already attached to the spacesuit! ";
        }
        else dobj.doAttachTo( actor, self );
    }
    ioAttachTo( actor, dobj ) =
    {
        self.ioPutIn( actor, dobj );
    }
;
tramShip: room
    launchState = 0     // 0 ==> docked at spacestation
    hasScored = nil     // updated by daemon tram2station
    sdesc = "Tram"
    ldesc =
    {
        "You are in a TripMaster 2000 (tm), the top of the
        line station to surface tram. There is a";
        if ( tramHatch.isopen ) "n open"; else " closed";
        " hatch to the
        north, a viewport to the south, and beneath the
        viewport is a control console. There are two seats
        here, one for the pilot and the other for a passenger.
        A short power cord ";
        if ( tramCord.isplugged )
        {
            "near the base of the console is plugged into ";
            tramCord.pluggedobj.adesc; ". ";
        }
        else "is near the base of the console. ";
    }
    north =
    {
        if ( tramHatch.isopen )
        {
            if ( self.launchState = 0 ) return( airLock3 );
            else return( planetLanding );
        }
        else
        {
            "The hatch is closed. ";
            setit( tramHatch );
            return( nil );
        }
    }
    leaveRoom( actor ) =
    {
        if ( actor.isCarrying( receptacle ) and
         car( receptacle.contents ) <> nil )
            receptacle.yankPlug;
        pass leaveRoom;
    }
    sleeping =
    {
        "\bAs you sleep, you are vaguely aware of being tossed to
        and fro.\b";
        tramHatch.isopen := true;
        remdaemon( tram2Planet, nil );
        global.sleepList := global.sleepList - tramShip;
        return( nil );
    }
;
tramHatch: doorway
    isopen = true
    doOpen( actor ) =
    {
        "This hatch is controlled automatically by the tram. ";
    }
    doClose( actor ) =
    {
        self.doOpen( actor );
    }
    noun = ['hatch']
    sdesc = "hatch"
    location = tramShip
;
autonavButton: buttonitem
    adjective = 'autonav'
    sdesc = "autonav button"
    location = startroom
    doPush( actor ) =
    {
        if ( self.isready )
        {
            if ( self.ispushed )
               "It doesn't help to push it over and over. ";
            else
            {
                "The computer's voice announces, \"Autonav
                now engaged. Stand by.\" The ship shudders
                briefly as the engines come on to turn the
                vessel on its new course. You just hope there's
                enough fuel to get you there. ";
                setfuse( shipland, 4, nil );
                self.ispushed := true;
            }
        }
        else "\"Click.\"";
    }
;
monster1: monsterItem
    adjective = 'brown'
    sdesc = "brown spiny-beaked pin-headed swamp weasel"
;
monster2: monsterItem
    adjective = 'black'
    sdesc = "black spiny-beaked pin-headed swamp weasel"
;
shuttle: fixeditem, vehicle, container
    location = quartersDepot
    isdroploc = true    // we can drop stuff here
    noun = 'shuttle' 'car'
    sdesc = "shuttle"
    ldesc =
    {
        "It's a two-seater self-levitating shuttle car, of a fairly old
        design. ";
        if ( canopy.isblown )
            "It used to have a canopy, but only the tattered remnants are
            in evidence now; the canopy must have been blown with explosive
            bolts (I wonder who could have done that?). ";
        else
            "It has a protective canopy, which is << canopy.isopen ?
             'open' : 'closed' >>. ";
        "Inside is a simple control panel for operating the shuttle. ";
    }
    inRem = 0
    outRem = 0
    doUnboard( actor ) =
    {
        if ( self.isActive )
            "It's far too dangerous to get out of the shuttle
            while it's running. ";
        else pass doUnboard;
    }
    out =
    {
        if ( self.isActive )
        {
            "It's far too dangerous to get out of the shuttle
            while it's running. ";
            return( nil );
        }
        else pass out;
    }
    // The destlist specifies which destination is reached with
    // a given autopilot setting.  The setting is contained in
    // shuttleDial.setting; the setting is merely an index into
    // this list
    destlist = [ /* escapeDepot */ quartersDepot landingDepot
      laserDepot reactorDepot ]

    sleeping =
    {
        if ( self.isActive and Me.location = self )
        {
            "You are quickly awakened by the noisy shuttle. ";
            return( true );
        }
        else
        {
            global.sleepList := global.sleepList - self;
            return( nil );
        }
    }
;
centralHub: room
    sdesc = "Central Hub"
    ldesc = "This is the central hub of the shuttle system, a huge
     cavernous area that allows shuttles from one depot to reach any
     other depot. The four walls are lined with tunnels; each wall is
     a three-by-three grid of tunnel entrances. "
;
tubeRubble: room
    tubeLength = 3
;
canopy: fixeditem
    location = shuttle
    noun = 'canopy'
    isopen = true
    sdesc = "canopy"
    ldesc =
    {
        if ( self.isblown )
            "Only the tattered remnants of the canopy are left.
            It appears that some evil person has blown the
            explosive bolts that were provided to eject the canopy
            in case of emergency. ";
        else "The canopy is << self.isopen ? "open" : "closed" >>. ";
    }
;
reactorDepot: depotRoom
    sdesc = "Reactor Depot"
    depotdesc = "This is the shuttle depot serving the
     reactor center. A passageway leads west. "
    shuttledir = "east"
    east = ( self.tunneldesc )
    west = reactorControl
    outTubeX = 1
    outTubeY = 4
    outTubeZ = 1
    tubeLength = 4
;
zeenite: item
    sdesc = "chunk of xenite"
    ldesc = "Xenite is a metallic substance; this is a good-sized
     chunk of the material. "
    noun = 'xenite' 'chunk'
    location = caveRoom143
    timer = 0
    doTake( actor ) =
    {
        if ( not self.hasScored )
        {
            self.hasScored := true;
            incscore( 20 );
        }
        pass doTake;
    }
;
joystick: fixeditem
    location = shuttle
    noun = ['joystick' 'stick']
    adjective = ['joy']
    sdesc = "joystick"
    ldesc =
    {
        "It can be moved to the eight compass points (relative
        to the shuttle): north, south, east, west, northeast,
        northwest, southeast, southwest. It's currently in the ";
        if ( self.ycoord = 1 ) "north";
        else if ( self.ycoord = -1 ) "south";
        if ( self.xcoord = 1 ) "east";
        else if ( self.xcoord = -1 ) "west";
        if ( self.xcoord=0 and self.ycoord=0 ) "center";
        " position. (To move the joystick, you might try a command
	such as \"move joystick southeast\" or \"center joystick.\") ";
    }
    xcoord = 0
    ycoord = 0
    verDoPush( actor ) = { "You should try something like \"move joystick
     north.\""; }
    verDoPull( actor ) = { "You should try something like \"move joystick
     south.\""; }
    verDoMoveN( actor )  = {}
    verDoMoveS( actor )  = {}
    verDoMoveE( actor )  = {}
    verDoMoveW( actor )  = {}
    verDoMoveNE( actor ) = {}
    verDoMoveNW( actor ) = {}
    verDoMoveSE( actor ) = {}
    verDoMoveSW( actor ) = {}
    verDoCenter( actor ) = {}
    genMove( x, y, n ) =
    {
        if ( autopilotSwitch.isOn )
        {
            "You can't seem to move the joystick. You notice that
            the panel's annunciator light indicates that the autopilot
            feature of the shuttle is engaged, which might explain
            why you cannot steer manually. ";
            exit;
        }
        if ( self.xcoord=x and self.ycoord=y )
        {
            "It's already as far "; say( n ); " as it goes. ";
        }
        else
        {
            "Okay, it's now in the "; say( n ); " position. ";
            self.xcoord := x;
            self.ycoord := y;
        }
    }
    doMoveN( actor )  = { self.genMove(  0,  1, 'north' ); }
    doMoveS( actor )  = { self.genMove(  0, -1, 'south' ); }
    doMoveE( actor )  = { self.genMove(  1,  0, 'east' ); }
    doMoveW( actor )  = { self.genMove( -1,  0, 'west' ); }
    doMoveNE( actor ) = { self.genMove(  1,  1, 'northeast' ); }
    doMoveNW( actor ) = { self.genMove( -1,  1, 'northwest' ); }
    doMoveSE( actor ) = { self.genMove(  1, -1, 'southeast' ); }
    doMoveSW( actor ) = { self.genMove( -1, -1, 'southwest' ); }
    doCenter( actor ) =
    {
        if ( self.xcoord=0 and self.ycoord=0 )
            "It's already as well centered as you can get it. ";
        else
        {
            "Okay, the joystick is now in its center position. ";
            self.xcoord := self.ycoord := 0;
        }
    }
;
airvent2: room
    sdesc = "Air Vent"
    ldesc =
    {
        "You are in an airvent.  To the south,
        the airvent has collapsed. Evidently, this airvent is
        suspended over the huge shuttle hub; the gaping hole
        to the south affords you a spectacular overhead view
        of the vast chamber below, but also provides a dangerous
        precipice.
        The vent continues
        to the north. ";
        if ( shuttle.isActive and shuttle.inRem = 0 and
         shuttle.outRem = 0 )
        {
            "\n\tAn empty shuttle is maneuvering below. ";
	    ventshuttle.ldesc;
        }
    }
    roomAction( a, v, d, p, i ) =
    {
        if ( v = jumpVerb or v = dVerb )
        {
            if ( shuttle.isActive and shuttle.inRem = 0 and
             shuttle.outRem = 0 and shuttle.xcoord = 1 and
             shuttle.ycoord = 3 )
            {
                "You gather your courage and jump off the ledge.
                You fall and fall, but fortunately, the shuttle
                has moved directly under you! ";
                if ( canopy.isblown )
                {
                    "You land on the floor of the shuttle
                    undamaged.\b";
                    a.travelTo( shuttle );
                    incscore( 5 );
                    exit;
                }
                else
                {
                    "Unfortunately, the canopy is closed, and
                    you bounce off the shuttle as it continues
                    on its way.  You continue to fall to the
                    hard floor far below.";
                    die();
                    abort;
                }
            }
            else
            {
                if ( v = dVerb ) pass roomAction;       // don't die on 'down'

                "It's really quite a long ways down. After an
                extended fall, you hit the hard floor below.";
                die();
                abort;
            }
        }
        else pass roomAction;
    }
    north = airvent1
;
ventshuttle: fixeditem, floatingItem
    noun = 'shuttle' 'car'
    verIoPutIn( actor ) = { "The shuttle is too far below you. "; }
    verIoPutOn( actor ) = { self.verIoPutIn( actor ); }
    verIoThrowAt( actor ) = { self.verIoPutIn( actor ); }
    locationOK = true
    location =
    {
        if ( shuttle.isActive and shuttle.inRem = 0 and
         shuttle.outRem = 0 )
        {
	    return( airvent2 );
	}
	else return( nil );
    }
    sdesc = "shuttle"
    ldesc =
    {
        "It is currently ";
        if ( shuttle.xcoord = 1 and shuttle.ycoord = 3 )
            "passing directly below";
        else if ( shuttle.xcoord = 1 )
        {
            if ( shuttle.ycoord = 2 ) "just";
            else "somewhat";
            " south of";
        }
        else if ( shuttle.ycoord = 3 )
        {
            if ( shuttle.xcoord = 2 ) "just";
            else "somewhat";
            " east of";
        }
        else "southeast of";
        " you. ";
    }
;
tubeRoom: room
    sdesc = "Transit Tube"
    ldesc = "The tube is nondescript and speeding by at high speed. "
;
gauntlet1: room
    sdesc = "Gauntlet"
    ldesc =
    {
        "You are in a very long hallway running east and west.
        The walls, floor, and ceiling are lined with a vast
        array of terrible-looking weapons, certainly designed
        to keep this corridoor safe from intruders. ";
        if ( pyrRobotRemains.location = self )
            "\n\tThe shattered remains of a destroyed robot
            litter the floor. ";

        "\n\t";
        if ( self.isPowerless ) // robot was just through
            "The huge array of weapons makes a half-hearted
            attempt to track you through the corridoor, but
            the battle with the robot apparently left it
            with insufficient energy to do you any harm.
            However, you can hear the sound of power supplies
            rapidly charging up, so you feel as though you
            should move quickly away from here. ";
        else                    // disactivated via security card
            "The vast array of weapons sits idly by, waiting
            for you to pass. ";
    }
    east = gauntletEntry
    west = gauntletDepot
    isActive = true
    enterRoom( actor ) =
    {
        if ( self.isActive )
        {
	    "Gauntlet\n\tYou find yourself in a very long hallway
	    running east and west.  You have the feeling that someone
	    is watching you.
	    \n\tSuddenly, you realize that something is indeed watching
	    you, and following your every move.  The walls, floor, and
	    ceiling of this hallway are lined with hundreds of deadly
	    weapons, all of which are humming with power,
	    and several security cameras are following your
	    every movement.
            \n\tBefore you can turn around to escape,
	    every one of the weapons turns
            toward you simultaneously. The weapons simply track
            you for a few moments, apparently confident that
            they can take the time to get their bearings perfect.
            You try to run, but it's too late; the weapons
            unleash a deadly volley of fire that you cannot
            escape. ";
            die();
        }
        else pass enterRoom;
    }
;
gauntletEntry: room
    sdesc = "Small Room"
    ldesc = "You're in a small room. A doorway to the east
        leads outside, and a small passage leads west. "
    east = quartersHall
    west =
    {
        if ( pyrRobot.isActive and pyrRobot.location = self )
        {
            "The robot moves to block your way. ";
            return( nil );
        }
        else return( gauntlet1 );
    }
;
gauntletDepot: room
    sdesc = "Commander's Quarters"
    ldesc =
    {
        "You are in a richly appointed room, which obviously
        serves as the commander's quarters. An exit is to the
        east. ";
        if ( gauntlet1.isActive )
            "A large red light over the exit, labelled \"Alarm
            Active - Do Not Enter\", is flashing insistently. ";
    }
    east = gauntlet1
;
shuttleBugNote: readable
    location = gauntletDepot
    sdesc = "yellow note"
    noun = 'note'
    adjective = 'yellow'
    ldesc = "It's a typewritten note on yellow paper. It reads:
     \n\t\"Note to shuttle users: the personal shuttle call device has a slight
     software error. If the shuttle call button is activated while the
     user is not at a shuttle depot, a shuttle will nonetheless be dispatched.
     Unfortunately, since the shuttle software has no way of determining which
     depot is closest to the caller, the shuttle will simply loop around the
     hub and return to the depot that it came from. Therefore, please avoid
     using the shuttle call device except while at a station; this will help
     prevent unnecessary congestion in the hub.\" "
;
escapeShip: room
    sdesc = "Spaceship"
    ldesc =
    {
        "You are in a small spaceship. The only notable feature of the
        controls is a small button labelled \"launch.\" ";
        if ( self.isActive )
            "The hatch is closed. ";
        else
            "An open hatch leads west. ";
    }
    west =
    {
        if ( self.isActive )
        {
            "The hatch is closed. ";
            return( nil );
        }
        else return( escapePad );
    }
    out = ( self.west )
    isActive = nil
    timer = 0
;
caveLake: room
    sdesc = "Lake Bed"
    ldesc = "You are on a dry lakebed (which appears to
     have been wet quite recently). The shore is to the north. "
    north = caveRoom1
;
class robotItem: Actor
    weight = 1000   // way too heavy to carry
    bulk = 1000     // likewise
    noun = ['robot' 'droid' 'droidmaster']
    sdesc = "robot"
    isActive = true
    actorAction( v, d, p, i ) =
    {
        if ( self.isActive )
            "The robot is just a domestic cleaning robot.
            This type of robot is generally not programmed to
            have lengthy conversations, especially with
            strangers. ";
        else
            "You must really be lonely, talking to a
            defunct robot. ";
        exit;
    }
    verDoTurnon( actor ) =
    {
        "You'll have to tell me how to do that. ";
    }
    verDoTurnoff( actor ) =
    {
        "Agreed, the robot is a nuisance, but you'll have to
        be more specific about how to deactivate it. ";
    }
;
stationMain: room
    sdesc = "Main Room"
    ldesc = "You are in the main room of the space station,
        which apparently serves as a lounge and recreation
        room; a chair and a couch are facing a tri-V.
        There is a kitchen to the north.  Hallways lead
        east and west, there are doors to the southeast
        and southwest, and a spiral staircase leads up and
        down. "
    north = stationKitchen
    east = stationDock
    west = stationTel
    se = stationBed1
    sw = stationBed2
    up = stationCon
    down = stationComp
;
stationTel: room
    sdesc = "Telescope"
    ldesc = "You are in a large room entirely enclosed by
        transparent walls, ceiling, and floor.  The view of
        the planet and the cosmos beyond is spectacular.
        There is a large telescope here, on a permanent base
        centered in what little of the floor is not
        transparent. A hallway leads east."
    roomAction( actor, v, dobj, prep, io ) =
    {
        if ( v = eVerb and car( receptacle.contents )<>nil
         and actor.isCarrying( receptacle ))
            receptacle.yankPlug;
        pass roomAction;
    }
    east = stationMain
;
planet: fixeditem
    location = stationTel
    noun = 'planet'
    sdesc = "planet"
    ldesc = "The planet is mostly covered by green and brown land masses
     under thin white clouds.  A large body of water in the northern
     hemisphere is visible near the horizon. "
;
stationBed2: room
    sdesc = "Bedroom"
    ldesc = "You are in a bedroom. A desk is against the wall,
       and a bed is in the center of the room.
       Doors lead north and east. "
    north = stationMain
    ne = stationMain
    east = stationLav
;
stationLav: room
    sdesc = "Lavatory"
    ldesc =
    {
        "You are in a lavatory.  There is a toilet and
        a sink here.  Above the sink is a mirrored medicine
        cabinet, which is ";
        if ( stationMedicine.isopen ) "open"; else "closed";
        ". Doors lead east and west. ";
    }
    east = stationBed1
    west = stationBed2
;
stationBed1: room
    sdesc = "Bedroom"
    ldesc = "You are in a bedroom. A desk is against one wall,
      and a bed is in the center of the room.
      Doors lead to the north and west. "
    nw = stationMain
    north = stationMain
    west = stationLav
;
stationDock: room
    north = airLock1
    east = airLock2
    south = airLock3
    west = stationMain
    up = stationAir1
    sdesc = "Docking Bay"
    ldesc = "You are in the main dock of the space station.
        There are gangways to the north, east, and south.
        A corridor leads west, and a stairway leads up. "
;
stationKitchen: room
    sdesc = "Kitchen"
    ldesc =
    {
        "You are in a kitchen. There is a microwave oven
        here (";
        if ( stationMicrowave.isopen ) "open"; else "closed";
        "), next to a large refrigerator (";
        if ( fridge.isopen ) "open"; else "closed";
        "). There is also a set of plastic shelves here.
        To the south is the main room of the station. ";
    }
    south = stationMain
    roomAction( actor, v, dobj, prep, io ) =
    {
        if ( v = sVerb ) fridge.isopen := nil;
        pass roomAction;
    }
;
vacRobotSlot: tapeSlotItem
    noun = 'slot'
    location = vacRobot
    isqcontainer = true
;
vacuumCleaner: item
    bulk = 2
    weight = 1
    noun = 'cleaner' 'suckmaster'
    adjective = 'vacuum'
    location = vacRobot
    sdesc = "vacuum cleaner"
    ldesc =
    {
        local isOn;

        "It's a SuckMaster 2000(tm), the top-of-the-line model. ";
        isOn := nil;
        if ( self.location = vacRobot or self.location = pyrRobot )
        {
            if ( self.location.isActive ) isOn := true;
        }
        if ( isOn ) "The vacuum is noisily running. ";
        else "It's a pretty normal-looking vacuum cleaner.
            Fortunately, it's off. ";
    }
    verDoTurnon( actor ) =
    {
        "For your own safety and the safety of those around you, the
        vacuum doesn't have a human-friendly power switch; only
        domestic robots are capable of activating it. ";
    }
;
seatbeltitem: fixeditem
    sdesc = "seat belt"
    ldesc =
    {
        "It's a BeltMaster 2000(tm), the top of the line model.
        If used properly, it will keep the occupant of the
        seat quite safe. ";
        if ( self.isfastened ) "It is currently fastened. ";
    }
    isfastened = nil
    verDoWear( actor ) = { self.verDoFasten( actor ); }
    doWear( actor ) = { self.doFasten( actor ); }
    verDoUnwear( actor ) = { self.verDoUnfasten( actor ); }
    doUnwear( actor ) = { self.doUnfasten( actor ); }
    verDoFasten( actor ) =
    {
        if ( self.isfastened ) "It's already fastened! ";
        else if ( actor.location <> self.location )
            "You can't fasten it from here. ";
    }
    doFasten( actor ) =
    {
        "Okay, "; self.thedesc; " is now fastened. ";
        self.isfastened := true;
        self.location.fastenitem := self;
    }
    verDoUnfasten( actor ) =
    {
        if ( not self.isfastened ) "It's not fastened! ";
        else if ( actor.location <> self.location )
            "You can't unfasten it from here. ";
    }
    doUnfasten( actor ) =
    {
        "Okay, "; self.thedesc; " is now unfastened. ";
        self.isfastened := nil;
        self.location.fastenitem := nil;
    }
;
shipHatch: doorway
    doOpen( actor ) =
    {
        Me.cantSleep := nil;
        if ( not startroom.isdocked )
        {
            "The HatchMaster 2000 (tm) has a noted safety
            problem, which is its tendency to allow untrained
            personnel to open it while in open space. You have
            now discovered this problem, but you are unfortunately
            sucked out into the vacuum before you have a chance
            to report it to consumer advocate Ralph Radon.";
            die();
        }
        else pass doOpen;
    }
    noun = ['hatch' 'hatchmaster']
    sdesc = "hatch"
    ldesc =
    {
        "The hatch, labelled with the snappy \"HatchMaster
        2000(tm)\" logo, is the top of the line model as spaceship
        hatches go.  It is currently ";
        pass ldesc;
    }
    location = startroom
;
dream: object
    setupDream =
    {
        Me.oldContents := Me.contents;
        Me.contents := [];
        Me.oldLocation := Me.location;
        Me.isasleep := true;
    }
    endDream =
    {
        local cur, rem;

        /*
         *   Drop all current contents into 'nil' - dream items shouldn't
         *   show up in waking world
         */
        rem := Me.contents;
        while ( cur := car( rem ))
        {
            cur.moveInto( nil );
            rem := cdr( rem );
        }

        "\bYou realize it was only a dream. You wake up refreshed.\b";
        Me.contents := Me.oldContents;
        Me.travelTo( Me.oldLocation );
        Me.isasleep := nil;
        abort;
    }
;
dreamLab: room
    sdesc = "Lab"
    ldesc = "You are in your high school's physics
     laboratory.  The only detail that seems interesting
     is a doorway leading east. "
    east = dreamLab2
;
airLock2: room
    west = stationDock
    east = startroom
    sdesc = "East Gangway"
    ldesc = "You are in a short passage.  An indicator light
        next to the open hatch to the east is green.  The
        station is to the west. "
;
stationEva1: vacroom
    sdesc = "Outside Airlock"
    ldesc =
    {
        "You are standing on the space station's hull, to the east of
        an airlock (whose door is open). The vast dark bulk of the
        solar collectors hangs above you, blocking out the sun. ";
        if ( goodbulb.location = suitSocket and spacesuit.islighton )
            "Handholds lead away to the north, south, and east. ";
        else
            "The darkness affords an excellent view of the heavens
            above, but it might make poking around out here rather
            dangerous. ";
    }
    west = stationAir
    north = stationEva2
    east = stationEva3
    south = stationEva4
    roomAction( a, v, d, p, i ) =
    {
        if ( v.isTravelVerb and
         not ( goodbulb.location = suitSocket and spacesuit.islighton ))
        {
            "You grope around in the dark for a bit, and then
            quite suddenly
            stumble over a handhold. That's enough to separate
            you from the low gravity of the station's exterior;
            your frantic efforts to grab hold of the station are
            to no avail as you sail off slowly into space... ";
            die();
        }
        else if ( v = uVerb or v = jumpVerb )
        {
            "In the relatively low gravity of the station's
            exterior, you easily separate yourself from the
            hull. You have about an hour to enjoy spectacular
            views of deep space, floating in total isolation... ";
            die();
        }
        else pass roomAction;
    }
;
stationAir1: room
    sdesc = "Small room"
    ldesc = "You are in a small dressing room.  A stairway leads
        down, and there is an open airlock to the east. "
    down = stationDock
    east = stationAir
    roomAction( actor, v, dobj, prep, io ) =
    {
        if ( v = dVerb and actor.isCarrying( spacesuit ))
        {
            "You'll never get down those stairs ";
            if ( spacesuit.isworn ) "wearing"; else "carrying";
            " that bulky ComfortMaster 2000(tm) spacesuit. ";
            exit;
        }
    }
;
fuse: fuseitem
    adjective = ['working' 'good']
    sdesc = "working fuse"
    ldesc = "It's a BlowMaster 2000(tm), the top of the line
        model. The fuse appears to be in fine working condition.
        It looks like a 200 Amp model. "
    location = powerCompartment
;
tramCompartment: fuseCompItem
    noun = ['compartment']
    adjective = ['fuse']
    location = tramEva
    compLabel = "The compartment is labelled
        \"Warning - No User Serviceable Parts Inside\". "
;
airhose: fixeditem
    noun = ['hose' 'tube' 'tubing']
    adjective = ['air' 'plastic']
    location = stationLab
    sdesc = "hose"
    ldesc =
    {
        "The hose is made of plastic, and is about two feet
        long. ";
        if ( self.attachment )
        {
            "The end of the hose is attached to ";
            self.attachment.adesc; ". ";
        }
    }
    verDoPutOn( actor, dobj ) = {}
    doPutOn( actor, dobj ) = { self.doAttachTo( actor, dobj ); }
    verIoAttachTo( actor ) = {}
    ioAttachTo( actor, dobj ) =
    {
        if ( dobj = suitTank ) dobj.doAttachTo( actor, self );
        else
        {
            "I don't know how to attach "; dobj.thedesc; " to the hose. ";
        }
    }
    verDoAttachTo( actor, io ) = {}
    doAttachTo( actor, io ) =
    {
        if ( io = suitTank ) io.doAttachTo( actor, self );
        else "I don't know how to attach the hose to that. ";
    }
    verIoDetachFrom( actor ) =
    {
        if ( self.attachment=nil ) "It's not attached to anything! ";
    }
    ioDetachFrom( actor, dobj ) =
    {
        dobj.doDetachFrom( actor, self );
    }
    verDoDetachFrom( actor, io ) =
    {
        if ( self.attachment <> io ) "It's not attached to that! ";
    }
    doDetachFrom( actor, io ) =
    {
        if ( io = suitTank ) io.doDetachFrom( actor, self );
        else pass doDetachFrom;
    }
    verDoDetach( actor ) =
    {
        if ( self.attachment=nil ) "It's not attached to anything! ";
    }
    doDetach( actor ) =
    {
        self.attachment.doDetachFrom( actor, self );
    }
    verDoTake( actor ) =
    {
        if ( self.attachment ) self.verDoDetach( actor );
        else pass verDoTake;
    }
    doTake( actor ) =
    {
        if ( self.attachment ) self.doDetach( actor );
        else pass doTake;
    }
;
suitSocket: socketitem
    location = spacesuit
    sdesc = "spacesuit socket"
    noun = ['socket']
    adjective = ['suit' 'spacesuit' 'space']
;
goodbulb: bulbitem
    noun = ['bulb' 'light' 'glowmaster']
    adjective = ['light' 'working' 'good']
    sdesc = "working bulb"
    ldesc =
    {
        if ( self.location = fridgeSocket or
          ( self.location = suitSocket and spacesuit.islighton ))
            "The bulb, a GlowMaster 2000(tm), is indeed glowing. ";
        else
            "The GlowMaster 2000(tm) is dark. ";
    }
    location = fridgeSocket
    doPutIn( actor, io ) =
    {
        if ( io = fridgeSocket or io = suitSocket and spacesuit.islighton )
            "The bulb starts glowing as you put it into the socket. ";
        else
            "Done. ";
        self.moveInto( io );
    }
;
tramCord: plugitem
    location = tramShip
    sdesc = "power cord"
    noun = ['cord' 'plug']
    adjective = ['power']
;
airLock3: room
    north = stationDock
    south = tramShip
    sdesc = "South Gangway"
    ldesc = "You are in a short passage. A green indicator
        light is glowing next to the open hatch to the
        south.  The station lies to the north. "
;
planetLanding: room
    south = tramShip
    sdesc = "South Landing Pad"
    ldesc = "You are standing on a large landing pad. To the
     south is your trusty tram. A walkway leads west, and a passageway
     leads north. "
    north = landingDepot
    west = walkway
    in = tramShip
;
receptacle: fixeditem, container
    location = powerSupply
    noun = 'receptacle'
    adjective = 'power'
    sdesc = "receptacle"
    ldesc =
    {
        "The power receptacle is covered with several layers
        of carbon deposits. ";
        if (car( self.contents ))
        {
            "There's "; car( receptacle.contents ).adesc;
            " plugged into it. ";
        }
        else
            "It looks like it will accept a standard power plug. ";
    }
    isreceptacle = true
    verIoPlugIn( actor ) = {}
    ioPlugIn( actor, dobj ) =
    {
        self.ioPutIn( actor, dobj );
    }
    verIoPutIn( actor ) =
    {
        if (car( self.contents ))
            "You can only plug one thing into the power supply at a time. ";
    }
    ioPutIn( actor, dobj ) =
    {
        if ( dobj.pluggedobj )
        {
            caps(); dobj.thedesc; " is already plugged into ";
            dobj.pluggedobj.thedesc; ". ";
        }
        else if ( dobj.isplug )
        {
            if ( fuse.location <> powerCompartment )
                caps();
            else if ( dobj.isShorted )
                "The power supply seems to explode in a
                terrifying shower of blue sparks and yellow
                and orange jets of flame as ";
            else
                "With a shower of blue sparks, ";
            dobj.thedesc; " slides snugly into the
            power receptacle. ";
            dobj.isplugged := true;
            dobj.pluggedobj := self;
            self.contents := self.contents + dobj;
            if ( dobj.isShorted and fuse.location = powerCompartment )
            {
                "Startled, you drop the power supply.  After
                a few moments, the sparks and flames stop, and
                the air is heavy with the acrid odor of burning
                electronic components. ";
                powerSupply.moveInto( actor.location );
                fuse.moveInto( nil );
                meltedFuse.moveInto( powerCompartment );
            }
        }
        else
        {
            caps(); dobj.thedesc; " doesn't seem to fit. ";
        }
    }
    verIoTakeOut( actor ) =
    {
        self.verIoUnplugFrom( actor );
    }
    ioTakeOut( actor, dobj ) =
    {
        self.ioUnplugFrom( actor, dobj );
    }
    verIoUnplugFrom( actor ) = {}
    ioUnplugFrom( actor, dobj ) =
    {
        caps(); dobj.thedesc; " comes free of the power supply";
        if ( fuse.location = powerCompartment )
         " with a brilliant display of electrical fireworks";
        ". ";
        self.contents := [];
        dobj.isplugged := nil;
        dobj.pluggedobj := nil;
    }
    yankPlug =
    {
        "\nYou hear a loud snap, ";
        if ( fuse.location = powerCompartment )
            "see some bright blue sparks, ";
        "and notice that you have yanked ";
        car( receptacle.contents ).thedesc; " out of the
        power supply. Remember, always pull out a power
        cord by the plug!\b";
        car( receptacle.contents ).isplugged := nil;
        car( receptacle.contents ).pluggedobj := nil;
        car( receptacle.contents ).isShorted := true;
        receptacle.contents := [];
    }
;
class monsterItem: fixeditem
    sdesc = "swamp weasel"
    noun = 'weasel'
    adjective = 'spiny-beaked' 'pin-headed' 'swamp'
    ismonster = true
;
quartersDepot: depotRoom
    sdesc = "Quarters Depot"
    depotdesc = "You are in the shuttle depot serving the
        living quarters. A hallway leads south. "
    shuttledir = "north"
    north = ( self.tunneldesc )
    south = quartersHall
    outTubeX = 3
    outTubeY = 0
    outTubeZ = 1
    tubeLength = 2
;
escapeDepot: depotRoom
    south = escapePad
    sdesc = "East Landing Pad Depot"
    depotdesc = "You are in a small room off the east landing pad, which
     lies to the south. "
    shuttledir = "west"
    west = ( self.tunneldesc )
    outTubeX = 4
    outTubeY = 2
    outTubeZ = 2
    tubeLength = 3
    ldesc =
    {
        if ( not self.isseen ) incscore( 5 );
        pass ldesc;
    }
;
landingDepot: depotRoom
    south = planetLanding
    sdesc = "South Landing Pad Depot"
    depotdesc = "You are in a small room off the south landing
     pad, which lies to the south. "
    shuttledir = "north"
    north = ( self.tunneldesc )
    outTubeX = 4
    outTubeY = 1
    outTubeZ = 2
    tubeLength = 3
;
laserDepot: depotRoom
    sdesc = "Laser Depot"
    depotdesc = "This is the depot serving the laser center.
     A hallway leads west. "
    west = laserHall
    shuttledir = "east"
    east = ( self.tunneldesc )
    outTubeX = 0
    outTubeY = 1
    outTubeZ = 2
    tubeLength = 3
;
class depotRoom: room
    isdepot = true
    lookAround( verbosity ) =
    {
        self.statusRoot;
	self.nrmLkAround( verbosity );
	if ( shuttle.location = self ) "\n\tA shuttle car is here. ";
    }
    ldesc =
    {
        self.depotdesc;
        "\n\tA yellow stripe painted on the floor denotes
        a danger area where the intra-base shuttle
        stops; the stripe disappears
        into a tunnel in the "; self.shuttledir ; " wall. ";
        if ( shuttle.location <> self ) "No shuttle is present. ";
    }
    tunneldesc =
    {
        "It's far too dangerous to venture down these
        tunnels. You could put out an eye. ";
        return( nil );
    }
;
reactorControl: room
    sdesc = "Reactor Control"
    ldesc =
    {
        "This is the reactor control room.  A passageway
         leads east. To the south is a ";
         if ( reactorDoor.isopen ) "stairway leading down. ";
         else "monstrous steel door, which is very securely closed. ";

         "\n\tThe reactor controls are quite complex; only a few
         features make much sense to you. On the wall is the Big
         Board, which has colored lights that indicate reactor status.
         A large console has many strange controls that you could not
         even begin to understand; the only controls that look
         approachable are four buttons labelled 1, 2, 3, and 4.";
    }
    east = reactorDepot
    down =
    {
        if ( reactorDoor.isopen ) return( reactorFloor );
        else
        {
            "The containment door is closed. ";
            return( nil );
        }
    }
    south = ( self.down )
;
caveRoom143: caveRoom
    down =
    {
        if ( not self.isscored )
        {
            "As you descend, you are startled to see a man in the cave
            below.  It's Pinback!  Before you can turn around, he comes
            up to you, wielding a large gun. \"So, you thought you could
            lose me in these caves? No such luck!\" He laughs; no, actually,
            he giggles, to be precise. \"I don't know what you think you're
            doing out here, but whatever it is, you're not going to stop me!
            I'm going to be Lord Pinback, Emperor of the Known Universe!\"
            He giggles at length, but his aim does not waver.
            \n\tIn the distance, you hear a familiar rumbling sound. Pinback
            doesn't seem to notice. He goes on talking and giggling. \"Lord
            Pinback... perhaps it is not sufficiently majestic a title for one
            so powerful as myself. King Pinback? Prince Pinback? Sir Pinback?
            Baron von Pinback?\" He goes on and on and on, and all the while
            the rumbling sound grows nearer.
            \n\tSuddenly, Pinback notices the approaching water. He looks
            away for a moment; you take the chance to escape back to the
            higher ground. Below, the water rushes through the cave; you
            hear Pinback's maniacal laughter as he is swept away into
            the distance. ";

            self.isscored := true;
            global.cavetime := 0;
            return( nil );
        }
        else return( caveRoom142 );
    }
    dirdesc = "down"
    iscaveledge = true
;
autopilotSwitch: controlSwitch
    adjective = 'autopilot'
    sdesc = "autopilot switch"
    isOn = true
    doTurnon( actor ) =
    {
        if ( actor.location = shuttle )
            "You notice that the annunciator light on the panel
            that indicates \"Autopilot Engaged\" lights up. ";
        pass doTurnon;
    }
    doTurnoff( actor ) =
    {
        if ( actor.location = shuttle )
            "You notice that the annunciator light on the panel
            that indicates \"Autopilot Engaged\" goes off. ";
        pass doTurnoff;
    }
;
airvent1: room
    sdesc = "Air Vent"
    ldesc = "You are in an airvent.  You can
     go north and south. "
    north = airshaft4
    south = airvent2
;
pyrRobotRemains: fixeditem
    noun = 'robot' 'droidmaster' 'pile' 'heap' 'remains'
    adjective = 'destroyed'
    sdesc = "destroyed robot"
    ldesc = "You recognize the remains of a DroidMaster 2000(tm),
        the top-of-the-line model when it was in one piece. Now it's
        a pile of crushed top-of-the-line parts. "
;
quartersHall: room
    sdesc = "Hall"
    ldesc = "You are in a north-south hall.  A doorway leads
        west; it is marked \"Private.\""
    north = quartersDepot
    south = quartersCommon
    west = gauntletEntry
;
pyrRobot: robotItem
    location = gauntletEntry
    actorDesc =
    {
        "A large domestic robot is here. ";
        if ( self.isActive )
            "It stands blocking the passage to the west,
            eying you suspiciously. From the looks of it, the robot
            is running GuardMaster 2000(tm) security software. ";
    }
    isActive = true
    ldesc =
    {
        "It's a DroidMaster 2000(tm), the top of the line model.
        The robot appears to be the domestic type. It has a slot
        for program tapes, which ";
        if (car( pyrRobotSlot.contents ))
        {
            "contains "; car( pyrRobotSlot.contents ).adesc; ". ";
        }
        else "is empty. ";
    }
    verGrab( item ) =
    {
        if ( self.isActive )
        {
            "The robot slaps your hand as you try to take ";
            item.thedesc; ", and looks at you sternly. ";
        }
    }
;
escapePad: room
    sdesc = "Launch Pad"
    ldesc =
    {
        "You are on a launch pad. To the
        east is a small spaceship. A path leads
        into dense vegetation to the west. A
        shuttle depot lies to the north. ";
        if ( guard.location = self )
        {
            "\n\t"; caps(); guard.adesc; " is here. It seems to be guarding the
            entrance to the spaceship. ";
        }
    }
    north = escapeDepot
    east =
    {
        if ( guard.location = self )
        {
            caps(); guard.thedesc; " won't let you go that way. ";
            return( nil );
        }
        else
            return( escapeShip );
    }
    west = swampEntry
;
caveRoom1: room
    west =
    {
        global.cavetime := global.cavetime - 1;
        return( caveRoom2 );
    }
    east =
    {
        remdaemon( caveDaemon, nil );
        global.sleepList := global.sleepList - cave1;
        return( cave1 );
    }
    south = caveLake
    sdesc = "Cave"
    ldesc = "You are in a cave. Passages lead east and west.
     A dry lakebed is to the south. "
;
vacroom: room
    isvac = true
;
stationEva2: hullRoom
    litedesc = "Handholds go off to the south; the dock to the
        north is empty. "
    south = stationEva1
;
stationEva3: hullRoom
    litedesc = "Handholds go off to the west; to the east is
        the roof of your trusty spaceship. "
    west = stationEva1
    east = shipEva
;
stationEva4: hullRoom
    litedesc = "Handholds go off to the north; to the south is
        the roof of a small tram ship. "
    north = stationEva1
    south = tramEva
;
class fuseitem: item
    noun = ['fuse' 'blowmaster']
    isfuse = true
;
powerCompartment: fuseCompItem
    noun = ['compartment']
    adjective = ['small' 'black']
    location = powerSupply
    compLabel = "It's a small black compartment. "
    sdesc = "small black compartment"
;
fuseCompItem: openable, fixeditem
    isopen = nil
    sdesc = "compartment"
    ldesc =
    {
        self.compLabel;
        "It's "; if ( self.isopen ) "open, ";
        else "closed. ";
        if ( self.isopen )
        {
            if (car( self.contents ))
            {
                "and contains "; car( self.contents ).adesc; ". ";
            }
            else "and is empty. ";
        }
    }
    ioPutIn( actor, dobj ) =
    {
        if ( dobj.isfuse ) dobj.doPutIn( actor, self );
        else
        {
            caps(); dobj.thedesc; " won't fit in "; self.thedesc; ". ";
        }
    }
    doOpen( actor ) =
    {
        if ( self.lockscrew )
        {
            "There's "; self.lockscrew.adesc; " preventing you from
            doing that. ";
        }
        else pass doOpen;
    }
;
tramEva: evaRoom
    sdesc = "On the hull of the tram"
    ldesc = "You are on the roof of a small tram ship.
        A small compartment protrudes slightly from the hull.
        The space station lies to the north. "
    north = stationEva4
;
stationLab: room
    sdesc = "Lab"
    ldesc = "You are in a large room with a lab bench. On
        the bench is a large machine. A doorway leads west. "
    west = stationComp
    leaveRoom( actor ) =
    {
        if ( airhose.attachment )
        {
            if ( actor.isCarrying( airhose.attachment ))
            {
                "You feel a tug on "; airhose.attachment.thedesc;
                ", and remember that it was attached to the hose.
                The hose yanks itself free.\b";
                airhose.attachment.attachment := nil;
                airhose.attachment := nil;
            }
        }
        if ( car( receptacle.contents )<>nil and
         actor.isCarrying( receptacle ))
            receptacle.yankPlug;
    }
;
socketitem: fixeditem, qcontainer
    ldesc =
    {
        caps(); self.thedesc;
        if (car( self.contents ))
        {
            " contains "; car( self.contents ).adesc; ". ";
        }
        else
        {
            " is empty. ";
        }
    }
    ioPutIn( actor, dobj ) =
    {
        if (car( self.contents ))
        {
            "You can only put one thing in "; self.thedesc; " at a time. ";
        }
        else if ( not dobj.isbulb )
        {
            caps(); dobj.thedesc; " doesn't seem to fit into ";
            self.thedesc; ". ";
        }
        else dobj.doPutIn( actor, self );
    }
;
bulbitem: item
    isbulb = true
;
fridgeSocket: socketitem, qcontainer
    location = fridge
    sdesc = "refrigerator socket"
    noun = ['socket']
    adjective = ['refrigerator' 'fridge']
;
plugitem: fixeditem
    isplug = true
    ldesc =
    {
        "It looks like a standard high voltage electrical cord,
        with a standard power plug at the end. ";
        if ( self.isplugged )
        {
            "The cord is plugged into "; self.pluggedobj.adesc;
            ". ";
        }
        if ( self.isShorted )
            "The plug seems to be badly frayed; it might even
            be shorted out. ";
    }
    verDoPlugIn( actor, io ) = {}
    doPlugIn( actor, io ) =
    {
    }
    verDoUnplug( actor ) =
    {
        if ( not self.isplugged ) "It's not plugged into anything! ";
    }
    doUnplug( actor ) =
    {
        self.pluggedobj.ioUnplugFrom( actor, self );
    }
    verDoUnplugFrom( actor, io ) =
    {
        if ( self.pluggedobj <> io )
        {
            "It's not plugged into "; io.thedesc; "! ";
        }
    }
;
walkway: room
    sdesc = "Walkway"
    ldesc = "You are on a walkway between the east landing
        pad (to the east) and a large dome to the west. "
    east = planetLanding
    west = quartersEntry
;
powerSupply: item
    bulk = 4
    weight = 5
    noun = ['supply' 'ampmaster']
    adjective = 'power'
    sdesc = "power supply"
    ldesc =
    {
        "It's an AmpMaster 2000(tm) freestanding power supply,
        the top of the line model.
        On the front is a power receptacle, and on the back
        is a small black compartment. ";
        if (car( receptacle.contents ))
        {
            "Plugged into the AmpMaster's power receptacle is ";
            car( receptacle.contents ).adesc; ". ";
        }
    }
    location = stationCon
    verIoPutIn( actor ) =
    {
        receptacle.verIoPutIn( actor );
    }
    ioPutIn( actor, dobj ) =
    {
        receptacle.ioPutIn( actor, dobj );
    }
    verIoPlugIn( actor ) =
    {
        receptacle.verIoPlugIn( actor );
    }
    ioPlugIn( actor, dobj ) =
    {
        receptacle.ioPlugIn( actor, dobj );
    }
;
meltedFuse: fuseitem
    adjective = ['melted']
    sdesc = "melted fuse"
    ldesc = "It's barely recognizable as an almost completely
        melted BlowMaster 2000(tm). "
;
laserHall: room
    sdesc = "Hallway"
    ldesc = "You are in an east-west hallway.  To the
     north is a small room, and a short stairway to the
     south leads up. "
    east = laserDepot
    west = laserFloor1
    north = laserStorage
    south = laserControl
    up = laserControl
;
shuttleNote: readable
    sdesc = "scrap of paper"
    noun = 'scrap' 'paper'
    location = laserStorage
    ldesc = "The paper has some hand-written notes on it:
     \n\t\"quarters - bottom left - south\"
     \n\t\"east landing pad - center - east\"
     \n\t\"laser - left center - west\" "
;
reactorFloor: room
    sdesc = "Reactor Floor"
    ldesc = "You are at the north end of the
     reactor floor. Stairs lead up to a control
     room, and the floor continues to the south.
     A tunnel leads north. In one corner of the room is a large
     heap of melted power supplies, of the type that you encountered
     on the space station. "
    north = reactorTunnel
    up = reactorControl
    south = reactorFloor2
;
slagSupply: fixeditem
    noun = 'supply' 'supplies' 'heap' 'pile'
    adjective = 'melted' 'power'
    sdesc = "pile of melted power supplies"
    ldesc = "They're melted. You couldn't possibly have any use for them. "
    location = reactorFloor
;
caveRoom: room
    sdesc = "Cave"
    ldesc = "You are in a cave.  You can go << self.dirdesc >>. "
;
caveRoom142: caveRoom
    se = caveRoom140
    up = caveRoom143
    dirdesc = "southeast and up"
;
class controlSwitch: fixeditem
    ldesc = "It's currently in the << self.isOn ? "on" : "off" >> position. "
    noun = ['switch']
    location = controlUnit
    verDoFlip( actor ) = {}
    doFlip( actor ) =
    {
        if ( self.isOn ) self.doTurnoff( actor );
        else self.doTurnon( actor );
    }
    verDoSwitch( actor ) = {}
    doSwitch( actor ) = { self.doFlip( actor ); }
    verDoTurnon( actor ) =
    {
        if ( self.isOn ) "It's already on. ";
    }
    doTurnon( actor ) =
    {
        self.isOn := true;
        "Okay, << self.thedesc >> is now switched into the \"on\" position. ";
    }
    verDoTurnoff( actor ) =
    {
        if ( not self.isOn ) "It's already off. ";
    }
    doTurnoff( actor ) =
    {
        self.isOn := nil;
        "Okay, << self.thedesc >> is now in the \"off\" position. ";
    }
;
stationCon: room
    sdesc = "Control Room"
    ldesc = "You are in the station control room.  A large
        picture window covers one whole wall, offering a
        breathtaking view of the planet above.  There is a
        control panel here, consisting of little more than a
        keyboard and display screen.  A log reader is sitting
        on the control panel. "
    down = stationMain
    roomAction( actor, v, dobj, prep, io ) =
    {
        if ( v = dVerb and car( receptacle.contents ) <> nil
         and actor.isCarrying( receptacle ))
            receptacle.yankPlug;
        pass roomAction;
    }
;
stationComp: room
    sdesc = "Computer Room"
    ldesc = "You are in a computer room.  In the center of the
        room is a console. A stairway leads up,
        and a doorway is to the east. "
    east = stationLab
    up = stationMain
    roomAction( actor, v, dobj, prep, io ) =
    {
        if (( v = eVerb or v = uVerb ) and
         car( receptacle.contents ) <> nil and
         actor.isCarrying( receptacle ))
            receptacle.yankPlug;
        pass roomAction;
    }
;
stationMedicine: fixeditem, openable
    noun = ['mirror' 'cabinet']
    adjective = ['medicine' 'mirrored']
    sdesc = "medicine cabinet"
    isopen = nil
    location = stationLav
    ldesc =
    {
        if ( self.isopen )
        {
            if ( itemcnt( self.contents ))
            {
                "The medicine cabinet contains ";
                listcont( self );
                ". ";
            }
            else "The medicine cabinet is empty.";
        }
        else
        {
            "You see a goofy-looking face staring back at you. ";
        }
    }
    ioPutIn( actor, dobj ) =
    {
        if ( dobj.bulk > 1 )
        {
            caps(); dobj.thedesc; " is too big to fit into the cabinet. ";
        }
        else pass ioPutIn;
    }
;
airLock1: room
    south = stationDock
    north =
    {
        "The hatch is closed, and, as there is no ship
        docked, opening it is not highly recommended. ";
        return nil;
    }
    sdesc = "North Gangway"
    ldesc = "You are in a short passage.  The main dock lies
        to the south, and a closed hatch is to the north.
        An indicator light next to the hatch is glowing red. "
;
stationMicrowave: decoration, openable
    sdesc = "microwave oven"
    noun = ['oven']
    adjective = ['microwave']
    location = stationKitchen
    isopen = nil
    verDoTurnon( actor ) = {}
    doTurnon( actor ) =
    {
        "Nothing happens. Perhaps the microwave is out of order. ";
    }
    verDoTurnoff( actor ) = { "It's not on. "; }
;
fridge: openable, fixeditem
    location = stationKitchen
    isopen = nil
    noun = ['refrigerator' 'fridge' 'chillmaster']
    adjective = ['large']
    sdesc = "refigerator"
    doLookin( actor ) =
    {
        self.ldesc;
    }
    ldesc =
    {
        "It's a ChillMaster 2000(tm), the top of the line
        model. The refigerator is ";
        if ( self.isopen )
        {
            "open. It seems that someone was hungry, because ";
            if ( goodbulb.location = fridgeSocket )
            {
                "the refrigerator's light illuminates ";
                if (itemcnt( self.contents ))
                {
                    "only "; listcont( self ); ". ";
                }
                else
                    "bare shelves. ";
            }
            else
            {
                "the dark compartment ";
                if (itemcnt( self.contents ))
                {
                    "contains only ";
                    listcont( self ); ". ";
                }
                else
                    "is empty. ";
                if (car( fridgeSocket.contents ))
                {
                    "The light bulb socket at the back of the
                    refrigerator contains ";
                    car( fridgeSocket.contents ).adesc; ". ";
                }
                else
                    "An empty light bulb socket is at the back of
                    the refrigerator. ";
            }
        }
        else "closed. ";
    }
;
tapeSlotItem: fixeditem, container
    sdesc = "slot"
    ldesc =
    {
        if (car( self.contents ))
        {
            "The slot contains "; car( self.contents ).adesc; ". ";
        }
        else "The slot is empty. ";
    }
    ioPutIn( actor, dobj ) =
    {
        if (car( self.contents ))
        {
            "You'll have to take "; car( self.contents ).thedesc;
            " out of "; self.thedesc; " first. ";
        }
        else if ( not dobj.istape )
        {
            caps(); dobj.thedesc; " won't fit in "; self.thedesc; ". ";
        }
        else dobj.doPutIn( actor, self );
    }
;
quartersCommon: room
    sdesc = "Common Room"
    ldesc = "This is the common room for the base's quarters.
        Exits lie east, west, north, and south. "
    east = quartersEntry
    north = quartersHall
    south = quartersBarracks
    west = quartersMess
;
pyrRobotSlot: tapeSlotItem
    location = pyrRobot
    noun = ['slot']
;
swampEntry: room
    west = swampG5
    sdesc = "Swamp"
    ldesc = "You are on some high ground just to the east of
      a large, smelly swamp. To the east is a landing pad. "
    east = escapePad
;
caveRoom2: caveRoom
    north = caveRoom7
    east = caveRoom1
    west = caveRoom3
    ne = caveRoom19
    dirdesc = "north, east, west, and northeast"
;
cave1: room
    sdesc = "Cave Entrance"
    ldesc = "You are in a large cave. A passage leads
      north, and a tunnel leads to the west. "
    north = basement
    west =
    {
        global.cavetime := 0;
        setdaemon( caveDaemon, nil );
        global.sleepList := global.sleepList + self;
        return( caveRoom1 );
    }
    sleeping =
    {
        if ( Me.location.iscaveledge )
        {
            "\bAs you sleep, you are vaguely aware of the sounds of
            huge torrents of rushing water in the distance. You wonder
            if such dreams have any psychological meaning...\b";
            return( nil );
        }
        else
        {
            "\bShortly after you drift off, you are vaguely aware of
            a rumbling sound in the distance. Suddenly, you awaken
            to find yourself caught in a rush of water, which washes
            you through the caves into a subterranean lake. After
            a while, the water gradually drains away.\b";
            Me.travelTo( caveLake );
            global.cavetime := 0;
            return( true );
        }
    }
;
hullRoom: evaRoom
    sdesc = "On space station's hull"
    gendesc = "You're on the space station's hull. Solar
        reflectors above capture all of the sunlight and
        planetlight that might otherwise be illuminating
        this area. "
    darkdesc = "It's hard to see much except the stunning
        starfield all around. "
;
shipEva: evaRoom
    sdesc = "On the hull of your ship"
    ldesc = "You're on the roof of your own trusty space ship.
        Unfortunately, you never learned how to service this
        vehicle yourself, so there's nothing here you recognize.
        The space station lies to the west. "
    west = stationEva3
;
evaRoom: vacroom
    ldesc =
    {
        self.gendesc;
        if ( goodbulb.location = suitSocket and spacesuit.islighton )
            self.litedesc;
        else
            self.darkdesc;
    }
    roomAction( actor, v, dobj, prep, io ) =
    {
        if ( v.isTravelVerb and not
         ( goodbulb.location = suitSocket and spacesuit.islighton ))
        {
            "You stumble around in the dark for a bit, and suddenly
            trip on a handhold. This sends you spinning off into
            space. Your frantic flailing about is to no avail, and
            you find yourself slowly floating off into the void... ";
            die();
        }
        else if ( v = jumpVerb or v = uVerb )
        {
            "Wow! It's really quite easy to jump pretty amazingly
            high in such low gravity. For a few terrifying moments,
            you're afraid that the station's gravity is so low it's
            not going to pull you back. But wait! You're right! ";
            die();
        }
        else pass roomAction;
    }
;
quartersEntry: room
    sdesc = "Quarters Entry"
    ldesc = "You are in the entryway to a large dome,
        which provides housing to the base's many occupants.
        A walkway exits to the east; a large room lies to
        the west. "
    east = walkway
    west = quartersCommon
;
class laserItem: fixeditem
    noun = 'laser' 'cannon'
    adjective = 'laser'
    sdesc = "laser"
    ldesc = "It's a huge laser cannon, of the type generally found in
     planetary defense stations. The specific details of its operation,
     power, and range are classified. The laser is pointed
     high into the sky. "
;
laser1: laserItem
    location = laserFloor1
;
laser2: laserItem
    location = laserFloor2
;
laser3: laserItem
    location = laserFloor3
;
laser4: laserItem
    location = laserFloor4
;
laserFloor1: room
    sdesc = "Laser Floor East"
    ldesc = "This is the east end of the laser
     floor; a hallway leads out to the east.
     The enourmous laser cannon itself is to the west; you can go
     around it to the northwest and southwest. "
    east = laserHall
    nw = laserFloor2
    sw = laserFloor3
;
laserStorage: room
    sdesc = "Storage Room"
    ldesc = "You are in a small storage room. An exit is
     to the south. "
    south = laserHall
;
laserControl: room
    sdesc = "Laser Control Room"
    ldesc = "You're in the laser control room. The room is in terrible
     condition; all of the equipment has been removed, leaving empty
     walls where control panels were evidently once installed. A
     stairway to the north leads down. "
    north = laserHall
    down = laserHall
;
reactorTunnel: room
    sdesc = "Tunnel"
    ldesc = "You are in a north-south tunnel. "
    north = reactorCooling
    south = reactorFloor
;
reactorFloor2: room
    sdesc = "Reactor Floor"
    ldesc = "You are at the south end of the reactor
     floor. A metal stairway leads up to a catwalk, and another
     stairway leads down. "
    north = reactorFloor
    up = reactorCatwalk
    down = basement
    enterRoom( actor ) =
    {
        local c;

        /*
         *   Do a special containment check, to avoid allowing
         *   the zeenite to be shielded by a closed container.
         */
        c := zeenite;
        while ( c )
        {
            if ( c = self )
            {
                "You notice << zeenite.thedesc >> that you're carrying
                becoming very hot.  It starts to glow and bubble and
                emit noxious fumes.  You realize that it's
                probably about to explode, and try to discard it, but
                you're too late.  The explosion, as viewed from
                somewhere other than its very, very center, is
                really quite spectacular.  Unfortunately, you do
                not live long enough to see much of it.";
                die();
                abort;
            }
            c := c.location;
        }
        pass enterRoom;
    }
;
basement: room
    sdesc = "Basement"
    ldesc = "You are in a basement. A
        stairway leads up.  You can go south
        through a section of crumbled wall.
        A passage leads east. "
    east = airshaft1
    south = cave1
    up = reactorFloor2
;
airshaft1: room
    sdesc = "Bottom of Airshaft"
    ldesc = "You are at the bottom of a tall
      airshaft. A ladder leads up.  A
      passage leads west. "
    west = basement
    up = airshaft2
;
controlUnit: item
    noun = 'unit'
    adjective = 'portable' 'control'
    sdesc = "portable control unit"
    ldesc = "The control unit is a small, flat, plastic
      box with several switches and buttons.
      A switch labelled \"Alarm\"
      is in the << alarmSwitch.isOn ? "on" : "off" >> position,
      and another labelled \"Shuttle Autopilot\" is in the
      << autopilotSwitch.isOn ? "on" : "off" >> position.
      The unit also has a button labelled \"Shuttle Call\". "
    location = gauntletDepot
    doTake( actor ) =
    {
        if ( not self.hasScored )
        {
            self.hasScored := true;
            incscore( 20 );
        }
        pass doTake;
    }
;
quartersBarracks: room
    sdesc = "Barracks"
    ldesc = "This is the featureless barracks. An exit
        lies to the north. "
    north = quartersCommon
;
biobook: readable
    sdesc = "xeno-biology book"
    noun = 'book'
    adjective = 'xeno-biology' 'biology'
    location = quartersBarracks
    ldesc =
    {
        "The book is about the various flora and fauna of this
         planet. For example, one section describes at length ";
         monster1.thedesc; ", which is a terrifying man-eating
         predator that dwells in the many swamps covering this
         planet.  The book says that, while "; monster1.thedesc; "
         can easily take on a human, it is no match for ";
         guard.thedesc;", its only natural enemy.  Apparently,
         despite the creature's ferociousness, it is quite dim-witted, and
         easily startled, especially when confronted with a member
         of its own species (how it mates, nobody knows). The book also
         describes an interesting feature of "; guard.thedesc; ":
         its proclivity to move into man-made structures and use
         them as its nest. Many early settlers on this planet were
         surprised to find the fierce creature had taken over their
         primitive dwelling structures after returning from
         a busy day of wandering hither and yon. ";
    }
;
quartersMess: room
    sdesc = "Mess"
    ldesc = "This is the featureless mess hall. The exit,
        should you become bored here (perish the thought)
        lies to the east. "
    east = quartersCommon
;
rations: fooditem
    noun = 'rations'
    adjective = 'survival'
    adesc = "some survival rations"
    sdesc = "survival rations"
    amount = 10
    ldesc =
    {
        "The generic survival rations look fairly old, but this stuff
         lasts forever. ";
        if ( self.amount > 7 ) "There's a lot left. ";
        else if ( self.amount > 4 ) "There's a fair amount left. ";
        else if ( self.amount > 1 ) "There's still a few meals left. ";
        else "There's only one meal left. ";
    }
    doEat( actor ) =
    {
        self.amount := self.amount - 1;
        global.lastMealTime := 0;
        if ( self.amount = 0 )
        {
            "You finish off the rations. ";
            self.moveInto( nil );
        }
        else if ( self.amount > 7 )
            "The rations taste pretty good, but nothing spectacular.
            There's still quite a lot left. ";
        else if ( self.amount > 4 )
            "You eat some of the rations, which you
            find palatable. There's still plenty left. ";
        else if ( self.amount > 1 )
            "That was acceptable. There's still a fair amount left. ";
        else
            "It tastes edible. It looks like you could get one more
            meal out of the rations. ";
    }
    location = quartersMess
;
swampG5: swampRoom
    myplant = plantG5
    north = swampG6
    east = swampEntry
    dirdesc = "north, south, and east"
    south = swampG4
;
caveRoom7: caveRoom
    north = caveRoom8
    south = caveRoom2
    dirdesc = "north and south"
;
caveRoom3: caveRoom
    north = caveRoom6
    east = caveRoom2
    west = caveRoom4
    nw = caveRoom5
    dirdesc = "north, east, west, and northwest"
;
caveRoom19: caveRoom
    north = caveRoom20
    ne = caveRoom18
    sw = caveRoom2
    dirdesc = "north, northeast, and southwest"
;
laserFloor2: room
    sdesc = "Laser Floor North"
    ldesc = "You are north of the laser. You can go southeast
     and southwest. "
    se = laserFloor1
    sw = laserFloor4
;
laserFloor3: room
    sdesc = "Laser Floor South"
    ldesc = "You are at the south end of the laser floor.
     You can go northeast and northwest. "
    ne = laserFloor1
    nw = laserFloor4
;
reactorCooling: room
    sdesc = "Cooling Towers"
    ldesc = "You are at the reactor cooling towers.
      A tunnel leads south. "
    south = reactorTunnel
;
reactorCatwalk: room
    sdesc = "Catwalk"
    ldesc = "You are at the south end of a long catwalk
     suspended over the reactor floor. A stairway leads
     down. "
    down = reactorFloor2
    north = reactorCatwalk2
;
airshaft2: room
    sdesc = "Middle of Air Shaft"
    ldesc = "You are in the middle of
      a tall air shaft. A ladder leads
      up and down. "
    up = airshaft3
    down = airshaft1
;
alarmSwitch: controlSwitch
    adjective = 'alarm'
    sdesc = "alarm switch"
    isOn = true
    doTurnoff( actor ) =
    {
        if ( actor.location = gauntletDepot )
        {
            "As you flip the switch into the \"off\"
            position, you notice that the alarm light over the
            door turns off. ";
        }
        gauntlet1.isActive := self.isOn := nil;
    }
    doTurnon( actor ) =
    {
        if ( actor.location = gauntletDepot )
        {
            "As you flip the switch on, you notice that the alarm
            light over the door comes on. ";
        }
        else if ( actor.location = gauntlet1 )
        {
            "The terrible guns filling the room all suddenly
            come to life!  An \"intruder alert\" klaxon sounds,
            and the guns converge on you.  Without taking more
            than a few tenths of a second to aim, the guns all
            start to fire an entirely excessive volley of
            energy bolts and projectiles at you. ";
            die();
            abort;
        }
        gauntlet1.isActive := self.isOn := true;
    }
;
swampRoom: room
    isSwampRoom = true
    sdesc = "In the swamp"
    ldesc =
    {
        "You're in a large, foul swamp. It looks like you might
        be able to travel to the ";
        self.dirdesc; ". ";
    }
    noexit = { "The swamp is far too deep that way. "; return( nil ); }
    enterRoom( actor ) =
    {
        local monster;

        if ( monster := hasMonster( self ))
        {
            "As you enter the area, "; monsterItem.adesc; " emerges from
            the muck, growling and slavering fiercely. As it eyes its
            potential delicious and nutritious meal (i.e., you), it smacks
            its hideous lips
            with anticipation. You have the barely controllable urge to
            leave. ";
        }
        else
            pass enterRoom;
    }
    roomAction( a, v, d, p, i ) =
    {
        local monster;

        if ( v.isTravelVerb or v.issysverb ) pass roomAction;
        if ( monster := hasMonster( self ))
        {
            "Before you can do anything, "; monsterItem.thedesc;
            " eats you uncerimoniously, although rather disgustingly. ";
            die();
            abort;
        }
        else
            pass roomAction;
    }
    nrmLkAround( verbosity ) =
    {
        local c;

        if ( verbosity ) { "\n\t"; self.ldesc; }
        "\n\t";
        if (itemcnt( self.contents ))
        {
            "You see "; listcont( self ); " here. ";
        }
        listcontcont( self );
	"\n\t";
	if ( verbosity )
	{
	    "In front of you is a large and strange plant. It stands about
	    six feet high, and has a red spot ";
            if ( self.myplant.isPlant2 ) "and a blue spot ";
            "near its base. The top of the plant opens into huge jaws
	    that could easily hold a human. ";
	}
        if ( c := car( self.myplant.contents ))
        {
            if ( c.ismonster )
            {
                "The plant is struggling to hold "; c.adesc; " in
                its open jaws. "; caps(); c.thedesc; " looks
                almost comical in its horror at becoming plant food.
                It looks at you longingly, as though asking you to
                help it out of its predicament, and as though it has
                forgotten that not too long ago you were to be its
                meal. ";
            }
            else
            {
                "The plant is holding "; c.adesc; " in its jaws. ";
            }
        }
    }
;
plantG5: swampPlant
    location = swampG5
    myredspot = redSwampSpotG5
;
swampG6: swampRoom
    myplant = plantG6
    south = swampG5
    nw = swampF7
    dirdesc = "south and northwest"
;
swampG4: swampRoom
    myplant = plantG4
    south = swampG3
    dirdesc = "north, south, and west"
    west = swampF4
    north = swampG5
;
laserFloor4: room
    sdesc = "Laser Floor West"
    ldesc = "You are at the west end of the laser center.
     The laser is to the east; you can go around it to the
     northeast and southeast. "
    ne = laserFloor2
    se = laserFloor3
;
reactorCatwalk2: room
    sdesc = "Catwalk"
    ldesc = "You are in the middle of a long catwalk
     running north and south, suspended over the reactor
     floor. "
    north = reactorCatwalk3
    south = reactorCatwalk
;
airshaft3: room
    sdesc = "Middle of Air Shaft"
    ldesc = "You are in the middle of a tall
      air shaft.  A ladder leads up and
      down. "
    up = airshaft4
    down = airshaft2
;
caveRoom8: caveRoom
    north = caveRoom10
    south = caveRoom7
    up = caveRoom9
    dirdesc = "north, south, and up"
;
caveRoom6: caveRoom
    north = caveRoom46
    south = caveRoom3
    nw = caveRoom45
    dirdesc = "north, south, and northwest"
;
caveRoom4: caveRoom
    north = caveRoom5
    east = caveRoom3
    dirdesc = "north and east"
;
caveRoom5: caveRoom
    south = caveRoom4
    nw = caveRoom22
    se = caveRoom3
    dirdesc = "south, northwest, and southeast"
;
caveRoom20: caveRoom
    north = caveRoom21
    south = caveRoom19
    dirdesc = "north and south"
;
caveRoom18: caveRoom
    north = caveRoom17
    sw = caveRoom19
    dirdesc = "north and southwest"
;
class swampPlant: fixeditem
    sdesc = "plant"
    spotdesc = "The plant has a red spot on it. "
    ldesc =
    {
        local c;

        self.spotdesc;
        c := car( self.contents );
        if ( c <> nil )
        {
            "Sitting in the plant's open jaws is "; c.adesc; ". ";
        }
    }
    verDoLookin( actor ) = {}
    doLookin( actor ) =
    {
        local c;

        if ( c := car( self.contents ))
        {
            "The plant is holding "; c.adesc; " in its jaws. ";
        }
        else
            "As you try to get a look inside, the plant
            suddenly snaps its jaws at you. You jump back,
            escaping being caught in the plant just in the
            nick of time. ";
    }
;
redSwampSpotG5: redPlantSpot
    location = swampG5
    dirname = "east"
    nextroom = escapePad
;
plantG6: swampPlant
    location = swampG6
    myredspot = redSwampSpotG6
;
swampF7: swampRoom
    myplant = plantF7
    east = swampG7
    se = swampG6
    sw = swampE6
    west = swampE7
    dirdesc = "east, southeast, southwest, and west"
;
plantG4: swampPlant
    location = swampG4
    myredspot = redSwampSpotG4
;
swampG3: swampRoom
    myplant = plantG3
    north = swampG4
    sw = swampF2
    dirdesc = "north and southwest"
;
swampF4: swampRoom
    myplant = plantF4
    north = swampF5
    south = swampF3
    west = swampE4
    dirdesc = "north, south, east, and west"
    east = swampG4
;
class redPlantSpot: plantSpot
    color = "red"
;
redSwampSpotG6: redPlantSpot
    location = swampG6
    dirname = "west"
    nextroom = swampF6
    monstroom = swampE6
;
plantF7: swampPlant2
    location = swampF7
    myredspot = redSwampSpotF7
    mybluespot = blueSwampSpotF7
;
swampG7: swampRoom
    myplant = plantG7
    west = swampF7
    dirdesc = "west"
;
swampE6: swampRoom
    myplant = plantE6
    ne = swampF7
    east = swampF6
    dirdesc = "south, northeast, east, and west"
    south = swampE5
    west = swampD6
;
swampE7: swampRoom
    myplant = plantE7
    east = swampF7
    west = swampD7
    dirdesc = "east and west"
;
redSwampSpotG4: redPlantSpot
    location = swampG4
    dirname = "northeast"
    nextroom = escapePad
;
plantG3: swampPlant
    location = swampG3
    myredspot = redSwampSpotG3
;
swampF2: swampRoom
    myplant = plantF2
    ne = swampG3
    south = swampF1
    west = swampE2
    dirdesc = "north, east, northeast, south, and west"
    east = swampG2
    north = swampF3
;
plantF4: swampPlant
    location = swampF4
    myredspot = redSwampSpotF4
;
swampF5: swampRoom
    myplant = plantF5
    north = swampF6
    south = swampF4
    dirdesc = "north and south"
;
swampF3: swampRoom
    myplant = plantF3
    north = swampF4
    dirdesc = "north and south"
    south = swampF2
;
swampE4: swampRoom
    myplant = plantE4
    east = swampF4
    dirdesc = "north, south, and east"
    north = swampE5
    south = swampE3
;
reactorCatwalk3: room
    sdesc = "Catwalk"
    ldesc = "You are at the north end of a long catwalk
     suspended over the reactor floor. A platform is to
     the east. "
    east = reactorCrane
    south = reactorCatwalk2
;
reactorCrane: room
    sdesc = "Crane Platform"
    ldesc = "You are on the crane control platform.
     A catwalk is to the west. "
    west = reactorCatwalk3
;
class plantSpot: fixeditem
    sdesc = { self.color; " spot"; }
    verDoTouch( actor ) = {}
    verDoPoke( actor ) = {}
    verDoPush( actor ) = {}
    doTouch( actor ) = { self.doPush( actor ); }
    doPoke( actor ) = { self.doPush( actor ); }
    doPush( actor ) =
    {
        local ejectile, monster, omonster;

        ejectile := car( self.location.myplant.contents );
        if ( ejectile = nil )
            "The plant sends up a big spout of water. ";
        else
        {
            if ( ejectile.isballoon )
            {
                "The plant ejects "; ejectile.thedesc;
                ", sending it high into the air to the ";
                self.dirname; ". ";

                if ( self.nextroom = escapePad )
                {
		    "Overhead, a huge black bird swoops down on ";
		    ejectile.thedesc; ", grabbing it in its talons.
		    The bird flies away to the southwest. After a while,
		    the bird seems to lose its grip, and "; ejectile.thedesc;
		    " drops into the swamp. A few moments later, you hear
		    a loud \"fwoop\" far to the southwest. ";
		    
                    ejectile.moveInto( plantB1 );
                }
                else
                {
                    ejectile.moveInto( self.nextroom.myplant );
                    if ( monster := hasMonster( self.nextroom ))
                    {
                        "Even as "; ejectile.thedesc; " whistles
                        through the air, you hear a terrified yelp
                        from the "; self.dirname; ", followed by
                        a loud \"fwoop\". ";
                        if ( omonster := hasMonster( self.monstroom ))
                        {
                            omonster.moveInto( self.monstroom.myplant );
                            "Moments later, from far away, you hear
                            a pair of horrified squeals, followed by
                            yet another, even louder \"fwoop\". To the ";
                            self.dirname; ", you hear rustling, and nervous
                            panting. ";
                        }
                        else
                        {
                            monster.moveInto( self.monstroom );
                        }
                    }
                    else
                    {
                        "Moments later, you hear a loud \"fwoop\". ";
                    }
                }
            }
            else
            {
                if ( self.nextroom <> escapePad )
                {
                    /*
                     *   Internal error DSD-3021:  not connected to swamp.
                     *   Somehow, we have two monsters in the same room, but
                     *   it's not the right room.  This should be impossible,
                     *   and means that the swamp is not working correctly.
                     *   This code should come out when DSD is considered
                     *   stable [yeah, right, like that'll ever happen -Ed.].
                     */
                    "A haggard implementor walks out of the swamp,
                    cursing under his breath (you hear such filthy language
                    as \"Internal Error DSD-3021\").  \"No, no, this isn't
                    right at all,\" he says, shaking his head. Here,
                    let's just sweep this one under the rug.\" With
                    a wave of his keyboard, he sends all the monsters
                    and balloons a-packing, making it impossible for
                    you to solve the swamp puzzle. (Serves you right
                    for breaking the game!) ";

                    monster1.moveInto( nil );
                    monster2.moveInto( nil );
                    balloon.moveInto( nil );
                }
                else
                {
                    "The plant does its usual ejection bit, sending
                    a confused and terrified "; ejectile.sdesc;
                    " arcing high overhead to the east. Moments later,
                    it lands, and quickly regains its senses. Seeing the
                    impressive "; guard.sdesc; ", "; monsterItem.thedesc;
                    " turns to run. But "; guard.thedesc; " won't let it
                    get away! "; caps(); guard.thedesc; " chases ";
                    monsterItem.thedesc; " past you into the swamp;
                    they disappear into the distance. ";
                    ejectile.moveInto( nil );
                    guard.moveInto( nil );
                    incscore( 50 );
                }
            }
        }
    }
;
guard: fixeditem
    sdesc = "saber-toothed triple-ringed xeno-beaver"
    noun = 'xeno-beaver' 'beaver'
    adjective = 'saber-toothed' 'triple-ringed' 'xeno'
    location = escapePad
;
swampF6: swampRoom
    myplant = plantF6
    south = swampF5
    west = swampE6
    dirdesc = "south and west"
;
class swampPlant2: swampPlant
    spotdesc = "The plant has a red spot and a blue spot on it. "
    isPlant2 = true
;
redSwampSpotF7: redPlantSpot
    location = swampF7
    dirname = "east"
    nextroom = swampG7
;
blueSwampSpotF7: bluePlantSpot
    location = swampF7
    dirname = "west"
    nextroom = swampE7
    monstroom = swampD7
;
plantG7: swampPlant
    location = swampG7
    myredspot = redSwampSpotG7
;
plantE6: swampPlant
    location = swampE6
    myredspot = redSwampSpotE6
;
swampE5: swampRoom
    myplant = plantE5
    sw = swampD4
    dirdesc = "north, south, and southwest"
    south = swampE4
    north = swampE6
;
swampD6: swampRoom
    myplant = plantD6
    north = swampD7
    south = swampD5
    dirdesc = "north, south, and east"
    east = swampE6
;
plantE7: swampPlant
    location = swampE7
    myredspot = redSwampSpotE7
;
swampD7: swampRoom
    myplant = plantD7
    south = swampD6
    sw = swampC6
    east = swampE7
    dirdesc = "south, east, and southwest"
;
redSwampSpotG3: redPlantSpot
    location = swampG3
    dirname = "north"
    nextroom = swampG4
    monstroom = swampG5
;
plantF2: swampPlant2
    location = swampF2
    myredspot = redSwampSpotF2
    mybluespot = blueSwampSpotF2
;
swampF1: swampRoom
    myplant = plantF1
    north = swampF2
    east = swampG1
    west = swampE1
    dirdesc = "north, east, and west"
;
swampE2: swampRoom
    myplant = plantE2
    north = swampE3
    east = swampF2
    dirdesc = "north, east, west, and northwest"
    west = swampD2
    nw = swampD3
;
swampG2: swampRoom
    myplant = plantG2
    south = swampG1
    dirdesc = "south and west"
    west = swampF2
;
redSwampSpotF4: redPlantSpot
    location = swampF4
    dirname = "west"
    nextroom = swampE4
    monstroom = swampD4
;
plantF5: swampPlant
    location = swampF5
    myredspot = redSwampSpotF5
;
plantF3: swampPlant
    location = swampF3
    myredspot = redSwampSpotF3
;
plantE4: swampPlant
    location = swampE4
    myredspot = redSwampSpotE4
;
swampE3: swampRoom
    myplant = plantE3
    south = swampE2
    nw = swampD4
    dirdesc = "north, south, and northwest"
    north = swampE4
;
plantB1: swampPlant2
    location = swampB1
    myredspot = redSwampSpotB1
    mybluespot = blueSwampSpotB1
;
balloon: fixeditem
    isballoon = true
    sdesc = "balloon"
    noun = ['balloon']
;
plantF6: swampPlant2
    location = swampF6
    myredspot = redSwampSpotF6
    mybluespot = blueSwampSpotF6
;
class bluePlantSpot: plantSpot
    color = "blue"
;
redSwampSpotG7: redPlantSpot
    location = swampG7
    dirname = "south"
    nextroom = swampG6
    monstroom = swampG5
;
redSwampSpotE6: redPlantSpot
    location = swampE6
    dirname = "east"
    nextroom = swampF6
    monstroom = swampG6
;
plantE5: swampPlant
    location = swampE5
    myredspot = redSwampSpotE5
;
swampD4: swampRoom
    myplant = plantD4
    ne = swampE5
    se = swampE3
    west = swampC4
    dirdesc = "northeast, southeast, and west"
;
plantD6: swampPlant
    location = swampD6
    myredspot = redSwampSpotD6
;
swampD5: swampRoom
    myplant = plantD5
    north = swampD6
    west = swampC5
    dirdesc = "north and west"
;
redSwampSpotE7: redPlantSpot
    location = swampE7
    dirname = "south"
    nextroom = swampE6
    monstroom = swampE5
;
plantD7: swampPlant
    location = swampD7
    myredspot = redSwampSpotD7
;
swampC6: swampRoom
    myplant = plantC6
    ne = swampD7
    sw = swampB5
    dirdesc = "northeast, west, and southwest"
    west = swampB6
;
redSwampSpotF2: redPlantSpot
    location = swampF2
    dirname = "south"
    nextroom = swampF1
;
blueSwampSpotF2: bluePlantSpot
    location = swampF2
    dirname = "southwest"
    nextroom = swampE1
;
plantF1: swampPlant2
    location = swampF1
    myredspot = redSwampSpotF1
    mybluespot = blueSwampSpotF1
;
swampG1: swampRoom
    myplant = plantG1
    north = swampG2
    west = swampF1
    dirdesc = "north and west"
;
swampE1: swampRoom
    myplant = plantE1
    east = swampF1
    west = swampD1
    dirdesc = "east and west"
;
plantE2: swampPlant
    location = swampE2
    myredspot = redSwampSpotE2
;
swampD2: swampRoom
    myplant = plantD2
    south = swampD1
    west = swampC2
    dirdesc = "south, east, and west"
    east = swampE2
;
swampD3: swampRoom
    myplant = plantD3
    sw = swampC2
    dirdesc = "southeast and southwest"
    se = swampE2
;
plantG2: swampPlant
    location = swampG2
    myredspot = redSwampSpotG2
;
redSwampSpotF5: redPlantSpot
    location = swampF5
    dirname = "southwest"
    nextroom = swampE4
    monstroom = swampD3
;
redSwampSpotF3: redPlantSpot
    location = swampF3
    dirname = "southeast"
    nextroom = swampG2
;
redSwampSpotE4: redPlantSpot
    location = swampE4
    dirname = "west"
    nextroom = swampD4
    monstroom = swampC4
;
plantE3: swampPlant2
    location = swampE3
    myredspot = redSwampSpotE3
    mybluespot = blueSwampSpotE3
;
swampB1: swampRoom
    myplant = plantB1
    north = swampB2
    ne = swampC2
    east = swampC1
    dirdesc = "north, east, and northeast"
    enterRoom( actor ) =
    {
        if ( self.isseen ) pass enterRoom;

        "As you enter this part of the swamp,
        you see a perplexing sequence unfold
        before your eyes. A huge "; monster1.sdesc; " leaps out of the muck,
        ready to attack. You clutch your heart in fear. Just as you think
        you've had it, "; monsterItem.thedesc; " looks with horror into the
        sky. From the southwest, high overhead you hear a
        whistling sound, as though a bomb were dropping out of the sky.
        You look up to see a huge black spherical object plummeting from
        the southwest. "; caps(); monster1.thedesc;
        " yelps and leaps to the northeast; a few
        moments later, the black spherical object lands in the open jaws
        of a huge plant in front of you with a \"fwoop\".\b";

        monster1.moveInto( swampC2 );
        monster2.moveInto( swampE3 );
        balloon.moveInto( plantB1 );

        pass enterRoom;
    }
;
redSwampSpotB1: redPlantSpot
    location = swampB1
    dirname = "northeast"
    nextroom = swampC2
    monstroom = swampD3
;
blueSwampSpotB1: bluePlantSpot
    location = swampB1
    dirname = "east"
    nextroom = swampC1
    monstroom = swampD1
;
redSwampSpotF6: redPlantSpot
    location = swampF6
    dirname = "north"
    nextroom = swampF7
;
blueSwampSpotF6: bluePlantSpot
    location = swampF6
    dirname = "south"
    nextroom = swampF5
    monstroom = swampF4
;
redSwampSpotE5: redPlantSpot
    location = swampE5
    dirname = "south"
    nextroom = swampE4
    monstroom = swampE3
;
plantD4: swampPlant
    location = swampD4
    myredspot = redSwampSpotD4
;
swampC4: swampRoom
    myplant = plantC4
    east = swampD4
    west = swampB4
    dirdesc = "east, west, and south"
    south = swampC3
;
redSwampSpotD6: redPlantSpot
    location = swampD6
    dirname = "southeast"
    nextroom = swampE5
    monstroom = swampF4
;
plantD5: swampPlant
    location = swampD5
    myredspot = redSwampSpotD5
;
swampC5: swampRoom
    myplant = plantC5
    east = swampD5
    dirdesc = "east and west"
    west = swampB5
;
redSwampSpotD7: redPlantSpot
    location = swampD7
    dirname = "east"
    nextroom = swampE7
    monstroom = swampF7
;
plantC6: swampPlant
    location = swampC6
    myredspot = redSwampSpotC6
;
swampB5: swampRoom
    myplant = plantB5
    ne = swampC6
    south = swampB4
    dirdesc = "north, east, northeast, and south"
    east = swampC5
    north = swampB6
;
swampB6: swampRoom
    myplant = plantB6
    ne = swampC7
    sw = swampA5
    dirdesc = "northeast, south, east, west, and southwest"
    south = swampB5
    west = swampA6
    east = swampC6
;
redSwampSpotF1: redPlantSpot
    location = swampF1
    dirname = "east"
    nextroom = swampG1
;
blueSwampSpotF1: bluePlantSpot
    location = swampF1
    dirname = "west"
    nextroom = swampE1
    monstroom = swampD1
;
plantG1: swampPlant
    location = swampG1
    myredspot = redSwampSpotG1
;
plantE1: swampPlant
    location = swampE1
    myredspot = redSwampSpotE1
;
swampD1: swampRoom
    myplant = plantD1
    north = swampD2
    east = swampE1
    west = swampC1
    dirdesc = "north, east, and west"
;
redSwampSpotE2: redPlantSpot
    location = swampE2
    dirname = "east"
    nextroom = swampF2
    monstroom = swampG2
;
plantD2: swampPlant2
    location = swampD2
    myredspot = redSwampSpotD2
    mybluespot = blueSwampSpotD2
;
swampC2: swampRoom
    myplant = plantC2
    north = swampC3
    ne = swampD3
    east = swampD2
    sw = swampB1
    dirdesc = "north, northeast, east, and southwest"
;
plantD3: swampPlant2
    location = swampD3
    myredspot = redSwampSpotD3
    mybluespot = blueSwampSpotD3
;
redSwampSpotG2: redPlantSpot
    location = swampG2
    dirname = "north"
    nextroom = swampG3
    monstroom = swampG4
;
redSwampSpotE3: redPlantSpot
    location = swampE3
    dirname = "northeast"
    nextroom = swampF4
    monstroom = swampG5
;
blueSwampSpotE3: bluePlantSpot
    location = swampE3
    dirname = "east"
    nextroom = swampF3
    monstroom = swampG3
;
swampB2: swampRoom
    myplant = plantB2
    north = swampB3
    south = swampB1
    dirdesc = "north and south"
;
swampC1: swampRoom
    myplant = plantC1
    east = swampD1
    dirdesc = "east and west"
    west = swampB1
;
plantB2: swampPlant
    location = swampB2
    myredspot = redSwampSpotB2
;
swampB3: swampRoom
    myplant = plantB3
    north = swampB4
    south = swampB2
    west = swampA3
    nw = swampA4
    dirdesc = "north, south, west, and northwest"
;
plantC2: swampPlant
    location = swampC2
    myredspot = redSwampSpotC2
;
swampC3: swampRoom
    myplant = plantC3
    south = swampC2
    dirdesc = "north and south"
    north = swampC4
;
plantC1: swampPlant
    location = swampC1
    myredspot = redSwampSpotC1
;
redSwampSpotB2: redPlantSpot
    location = swampB2
    dirname = "north"
    nextroom = swampB3
    monstroom = swampB4
;
plantB3: swampPlant
    location = swampB3
    myredspot = redSwampSpotB3
;
swampB4: swampRoom
    myplant = plantB4
    north = swampB5
    east = swampC4
    south = swampB3
    dirdesc = "north, east, and south"
;
swampA3: swampRoom
    myplant = plantA3
    east = swampB3
    south = swampA2
    dirdesc = "east and south"
;
swampA4: swampRoom
    myplant = plantA4
    north = swampA5
    se = swampB3
    dirdesc = "north and southeast"
;
redSwampSpotC2: redPlantSpot
    location = swampC2
    dirname = "southwest"
    nextroom = swampB1
;
plantC3: swampPlant2
    location = swampC3
    myredspot = redSwampSpotC3
    mybluespot = blueSwampSpotC3
;
redSwampSpotC1: redPlantSpot
    location = swampC1
    dirname = "northeast"
    nextroom = swampD2
    monstroom = swampE3
;
plantD1: swampPlant
    location = swampD1
    myredspot = redSwampSpotD1
;
redSwampSpotB3: redPlantSpot
    location = swampB3
    dirname = "north"
    nextroom = swampB4
    monstroom = swampB5
;
plantB4: swampPlant
    location = swampB4
    myredspot = redSwampSpotB4
;
plantA3: swampPlant
    location = swampA3
    myredspot = redSwampSpotA3
;
swampA2: swampRoom
    myplant = plantA2
    north = swampA3
    south = swampA1
    dirdesc = "north and south"
;
plantA4: swampPlant2
    location = swampA4
    myredspot = redSwampSpotA4
    mybluespot = blueSwampSpotA4
;
swampA5: swampRoom
    myplant = plantA5
    ne = swampB6
    south = swampA4
    dirdesc = "northeast and south"
;
redSwampSpotC3: redPlantSpot
    location = swampC3
    dirname = "southeast"
    nextroom = swampD2
    monstroom = swampE1
;
blueSwampSpotC3: bluePlantSpot
    location = swampC3
    dirname = "southwest"
    nextroom = swampB2
    monstroom = swampA1
;
plantC4: swampPlant
    location = swampC4
    myredspot = redSwampSpotC4
;
redSwampSpotD3: redPlantSpot
    location = swampD3
    dirname = "northeast"
    nextroom = swampE4
    monstroom = swampF5
;
blueSwampSpotD3: bluePlantSpot
    location = swampD3
    dirname = "east"
    nextroom = swampE3
    monstroom = swampF3
;
redSwampSpotD2: redPlantSpot
    location = swampD2
    dirname = "north"
    nextroom = swampD3
    monstroom = swampD4
;
blueSwampSpotD2: bluePlantSpot
    location = swampD2
    dirname = "south"
    nextroom = swampD1
;
redSwampSpotD1: redPlantSpot
    location = swampD1
    dirname = "east"
    nextroom = swampE1
    monstroom = swampF1
;
redSwampSpotD4: redPlantSpot
    location = swampD4
    dirname = "west"
    nextroom = swampC4
    monstroom = swampB4
;
redSwampSpotB4: redPlantSpot
    location = swampB4
    dirname = "north"
    nextroom = swampB5
    monstroom = swampB6
;
plantB5: swampPlant2
    location = swampB5
    myredspot = redSwampSpotB5
    mybluespot = blueSwampSpotB5
;
redSwampSpotA3: redPlantSpot
    location = swampA3
    dirname = "south"
    nextroom = swampA2
    monstroom = swampA1
;
plantA2: swampPlant
    location = swampA2
    myredspot = redSwampSpotA2
;
swampA1: swampRoom
    myplant = plantA1
    north = swampA2
    dirdesc = "north"
;
redSwampSpotA4: redPlantSpot
    location = swampA4
    dirname = "southeast"
    nextroom = swampB3
    monstroom = swampC2
;
blueSwampSpotA4: bluePlantSpot
    location = swampA4
    dirname = "south"
    nextroom = swampA3
    monstroom = swampA2
;
plantA5: swampPlant
    location = swampA5
    myredspot = redSwampSpotA5
;
redSwampSpotC4: redPlantSpot
    location = swampC4
    dirname = "south"
    nextroom = swampC3
    monstroom = swampC2
;
redSwampSpotE1: redPlantSpot
    location = swampE1
    dirname = "north"
    nextroom = swampE2
    monstroom = swampE3
;
redSwampSpotB5: redPlantSpot
    location = swampB5
    dirname = "northwest"
    nextroom = swampA6
;
blueSwampSpotB5: bluePlantSpot
    location = swampB5
    dirname = "east"
    nextroom = swampC5
    monstroom = swampD5
;
plantC5: swampPlant
    location = swampC5
    myredspot = redSwampSpotC5
;
plantB6: swampPlant
    location = swampB6
    myredspot = redSwampSpotB6
;
swampC7: swampRoom
    myplant = plantC7
    sw = swampB6
    west = swampB7
    dirdesc = "southwest and west"
;
swampA6: swampRoom
    myplant = plantA6
    north = swampA7
    ne = swampB7
    dirdesc = "north, east, and northeast"
    east = swampB6
;
redSwampSpotA2: redPlantSpot
    location = swampA2
    dirname = "south"
    nextroom = swampA1
;
plantA1: swampPlant
    location = swampA1
    myredspot = redSwampSpotA1
;
redSwampSpotA5: redPlantSpot
    location = swampA5
    dirname = "south"
    nextroom = swampA4
    monstroom = swampA3
;
redSwampSpotC6: redPlantSpot
    location = swampC6
    dirname = "north"
    nextroom = swampC7
;
redSwampSpotC5: redPlantSpot
    location = swampC5
    dirname = "east"
    nextroom = swampD5
    monstroom = swampE5
;
redSwampSpotB6: redPlantSpot
    location = swampB6
    dirname = "southwest"
    nextroom = swampA5
;
plantC7: swampPlant2
    location = swampC7
    myredspot = redSwampSpotC7
    mybluespot = blueSwampSpotC7
;
swampB7: swampRoom
    myplant = plantB7
    east = swampC7
    sw = swampA6
    dirdesc = "east and southwest"
;
plantA6: swampPlant2
    location = swampA6
    myredspot = redSwampSpotA6
    mybluespot = blueSwampSpotA6
;
swampA7: swampRoom
    myplant = plantA7
    south = swampA6
    dirdesc = "south"
;
redSwampSpotA1: redPlantSpot
    location = swampA1
    dirname = "east"
    nextroom = swampB1
    monstroom = swampC1
;
redSwampSpotG1: redPlantSpot
    location = swampG1
    dirname = "north"
    nextroom = swampG2
    monstroom = swampG3
;
/*
officersMessDepot: room
    sdesc = "Depot"
    ldesc = "Wow! Another depot! "

    outTubeX = 2
    outTubeY = 4
    outTubeZ = 2
    tubeLength = 3
;
*/
/*
pyramidBack: room
    sdesc = "Back of Pyramid"
    ldesc = "There's a large pyramid to the west. A small
        passage leads into the structure. In addition, a trail
        leads up a hill to the northwest. "
    up = planetHill
    nw = planetHill
    west = gauntletEntry
;
planetHill: room
    sdesc = "Hilltop"
    ldesc = "You are on a tall hill overlooking a vast forest.
        To the south is a huge building bearing a strong resemblance
        to the ancient pyramids of Earth and Omicron Ceti IV.
        To the north the forest abruptly ends in a swamp that
        stretches on to the horizon. Trails lead down the
        hill to the southeast, west, and southwest. "
    se = pyramidBack
    sw = pyramidFront
    west = planetTrail
    down =
    {
        "Several trails lead down the hill; you'll have to be
        more specific about which way you want to go. ";
        return( nil );
    }
;
pyramidFront: room
    sdesc = "Front of Pyramid"
    ldesc = "You are standing in a clearing. To the
        east is a large (closed) door leading into a
        gargantuan alien building. A trail leads into
        the forest to the west, and another trail leads
        up a hill to the northeast. "
    ne = planetHill
    up = planetHill
    west = planetLanding
;
planetTrail: room
    north = swampEntry
    sdesc = "Trail Junction"
    ldesc = "You are in a small clearing in the forest.
        Several trails come together here; you can go north
        or south, or up a trail climbing a tall hill to the east. "
    south = planetLanding
    east = planetHill
    up = planetHill
;
*/
redSwampSpotD5: redPlantSpot
    location = swampD5
    dirname = "north"
    nextroom = swampD6
    monstroom = swampD7
;
redSwampSpotC7: redPlantSpot
    location = swampC7
    dirname = "east"
    nextroom = swampD7
    monstroom = swampE7
;
blueSwampSpotC7: bluePlantSpot
    location = swampC7
    dirname = "south"
    nextroom = swampC6
    monstroom = swampC5
;
plantB7: swampPlant
    location = swampB7
    myredspot = redSwampSpotB7
;
redSwampSpotA6: redPlantSpot
    location = swampA6
    dirname = "north"
    nextroom = swampA7
;
blueSwampSpotA6: bluePlantSpot
    location = swampA6
    dirname = "northeast"
    nextroom = swampB7
;
plantA7: swampPlant2
    location = swampA7
    myredspot = redSwampSpotA7
    mybluespot = blueSwampSpotA7
;
redSwampSpotB7: redPlantSpot
    location = swampB7
    dirname = "east"
    nextroom = swampC7
    monstroom = swampD7
;
redSwampSpotA7: redPlantSpot
    location = swampA7
    dirname = "east"
    nextroom = swampB7
    monstroom = swampC7
;
blueSwampSpotA7: bluePlantSpot
    location = swampA7
    dirname = "southeast"
    nextroom = swampB6
    monstroom = swampC5
;
/*
returnTape: tapeitem
    noun = ['square' 'tape']
    adjective = ['green' 'plastic']
    plural = ['squares' 'tapes']
    sdesc = "square of green plastic"
    ldesc = "It's green, plastic, and square. "
    location = nil
    tramdest = 69814
;
*/
tapeitem: item
    istape = true
    logdesc = "\"General failure reading tape\", a
        mechanical voice announces. "
;
badfuse: fuseitem
    sdesc = "blown fuse"
    adjective = ['blown' 'bad']
    ldesc = "It's a BlowMaster 2000(tm), the top of the line
        model, and it's blown. It was a 200 Amp model in its
        healthier days. "
    location = tramCompartment
;
/*
screwitem: fixeditem
    sdesc = "screw"
    doTurnWith( actor, io ) =
    {
        if ( self.isturned ) self.doScrewWith( actor, io );
        else self.doUnscrewWith( actor, io );
    }
    doScrewWith( actor, io ) =
    {
        if ( io.isscrewdriver )
        {
            if ( self.lockitem.isopen )
            {
                "The screw turns, but, since "; self.lockitem.thedesc;
                " is open, nothing more happens. ";
            }
            if ( self.isturned ) "It's already screwed in. ";
            else
            {
                self.isturned := true;
                "Okay, it's now screwed in. ";
            }
        }
        else
        {
            "You can't seem to turn "; self.thedesc; " with "; io.thedesc;
            ". ";
        }
    }
    doUnscrewWith( actor, io ) =
    {
        if ( io.isscrewdriver )
        {
            if ( self.lockitem.isopen )
            {
                "The screw turns, but, since "; self.lockitem.thedesc;
                " is open, nothing more happens. ";
            }
            if ( not self.isturned ) "It's already unscrewed. ";
            else
            {
                self.isturned := true;
                "You manage to unscrew "; self.thedesc; ". ";
            }
        }
        else
        {
            "You can't seem to turn "; self.thedesc; " with "; io.thedesc;
            ". ";
        }
    }
    doScrew( actor ) =
    {
        "You'll need some sort of tool to do that. ";
    }
    doUnscrew( actor ) =
    {
        "You'll need some sort of tool to do that. ";
    }
;
*/
stationBench: surface, fixeditem
    noun = ['bench']
    adjective = ['lab']
    location = stationLab
    sdesc = "lab bench"
    ldesc =
    {
        if (itemcnt( self.contents ))
        {
            "In addition to the large machine dominating
            the center of the bench, you see ";
            listcont( self ); " on the bench. ";
        }
        else "There's a large machine on the bench. ";
    }
;
logTape: tapeitem
    noun = ['square' 'tape']
    plural = ['squares' 'tapes']
    adjective = ['yellow' 'plastic']
    sdesc = "square of yellow plastic"
    ldesc = "The piece of yellow plastic is square, about
        an eighth of an inch thick, and three inches on a side.
        Handwritten on one side is \"219-\". "
    location = stationConPanel
    logCount = 0
    logdesc =
    {
        self.logCount := self.logCount + 1;
        if ( self.logCount = 1 )
            "A man's voice comes from the machine: \"Day 219. Tram 1
            completely malfunctioned. I'm looking in the manual,
            but I'm probably going to have to get a repairman out here.\"";
        else if ( self.logCount = 2 )
            "The man's voice continues, \"Day 220. Fixed tram. It was the
            fuse again. Our supply of fuses is now completely exhausted.
            I'm going to have to risk going down to the planet today to
            scout the new landing site at coordinates 1701.\"";
        else if ( self.logCount = 3 )
            "The man's voice continues, \"Day 222. No report.\"";
        else if ( self.logCount = 4 )
            "The man's voice says, \"Day 223. Sigourney has asked me to
            enter into the log that her hairdrier has disappeared. I'm
            sure headquarters will be on this one right away, Sigourney.\"";
        else if ( self.logCount = 5 )
            "A woman's voice continues the log report. You quickly recognize
            it as the woman you spoke to earlier. \"Day 225. The maintenance
            robot has disappeared.\"";
        else if ( self.logCount = 6 )
            "The man's voice comes on again, sounding irate. \"Day 225.
            Disregard previous entry. The maintenance robot is simply down
            on the surface preparing the new landing site at 1701.\"";
        else if ( self.logCount = 7 )
            "The woman's voice comes on again. \"Day 227. So where's the
            robot, Pinback?\"";
        else if ( self.logCount = 8 )
            "The man's voice continues. \"Day 227. I'm having serious concerns
            about Sigourney's mental health.  She seems overly upset about
            small, everyday problems--\"
            The woman's voice, now quite hysterical, cuts in. \"What do
            you mean, concerns about my mental health, you little jerk?
            Everything's just disappearing and you call that--\"
            The man's voice cuts back in: \"Now, Sigourney, just calm down.
            If you'd let me finish, I'd have told you that the robot is
            broken, so I couldn't get it in the tram to--\"
            The woman's voice again: \"Broken? What could you have done to
            it to break it?\"
            The man's voice: \"Probably the fuse or something. Look, let's
            just turn this off--\"";
        else if ( self.logCount = 9 )
            "The man's voice continues. \"Day 230. I had to restrain
            Sigourney since she appears to be having a breakdown.\"";
        else if ( self.logCount = 10 )
            "The man continues, \"Day 231. Sigourney's condition appears
            to be getting worse the longer she is restrained. The sedatives
            are helping. I hesitate to inform headquarters, because I think
            this is a temporary condition she'll get over.\"";
        else if ( self.logCount = 11 )
            "The woman's voice, calm but angry, continues. \"Day 232.
            Pinback has gone mad. He's trying to reactivate the old
            military base on the planet. He has some kind of crazy plan
            that it will let him rule the galaxy. I have to stop him before
            he actually manages to find any weapons down there and hurts
            himself.\"";
        else
        {
            self.logCount := 0;
            "The log reader pauses, then rewinds itself. ";
            if ( not self.hasScored )
            {
                self.hasScored := true;
                incscore( 2 );
            }
        }
    }
;
stationConPanel: fixeditem, surface
    location = stationCon
    sdesc = "control panel"
    noun = 'panel' 'console'
    adjective = 'control'
    ldesc =
    {
        "The control panel consists of a display screen
        and a standard computer keyboard. A log reader is
        attached to the panel. ";
        inherited.ldesc;
    }
;
telescope: fixeditem
    noun = ['telescope' 'scope' 'scopemaster']
    sdesc = "telescope"
    telepos = 0
    telecolor = 'red'
    location = stationTel
    ldesc =
    {
        "It's a ScopeMaster 2000(tm), the top of the line
        model, featuring six position presets for your
        viewing convenience. The preset buttons on this
        telescope are red, green, blue, yellow, orange,
        and violet. There is a seat positioned just under
        the eyepiece, connected to the telescope
        by a large boom, protruding from the scope's
        stationary base. It looks like the seat would be
        perfectly positioned for viewing regardless of
        the orientation of the scope. There is a small cord
        attached to the telescope's base. ";
        if ( telepower.isplugged and fuse.location = powerCompartment )
        {
            "The \"power\" light is on, and the ";
            say( self.telecolor );
            " preselect button is glowing. ";
        }
        else
            "The \"power\" light is off. ";
    }
    look4cnt = 0
    thrudesc =
    {
        if ( self.telepos = 0 )
        {
            "You see a surprisingly high resolution view of
            the surface of the planet below. The view is of an
            old-style landing pad. ";
            if ( not self.isseen )
            {
                self.isseen := true;
                "You see a man moving equipment off the landing
                pad. It looks like he's carrying power supplies. ";
            }
        }
        else if ( self.telepos = 1 )
            "You see a lovely star field. ";
        else if ( self.telepos = 2 )
            "You see a striking nebula. ";
        else if ( self.telepos = 3 )
            "You see a huge surface-to-orbit laser. It looks to be
            aimed essentially directly at the space station. ";
        else if ( self.telepos = 4 )
        {
            "The telescope is trained on the horizon of the planet. ";
            if ( not self.shuttleseen )
            {
                "As you watch, a small tram ship flies through your
                field of view. It seems to be in a low orbit around
                the planet, spinning out of control. ";
                self.shuttleseen := true;
            }
        }
        else if ( self.telepos = 5 )
            "You see a rather dull void. ";
    }
    verDoLookin( actor ) = {}
    doLookin( actor ) =
    {
        self.thrudesc;
    }
    verDoLookthru( actor ) = {}
    doLookthru( actor ) =
    {
        self.thrudesc;
    }
;
telepower: plugitem
    location = stationTel
    sdesc = "power cord"
    noun = ['cord' 'plug']
    adjective = ['power']
;
class telebuttonsc: buttonitem
    location = stationTel
    islit = nil
    sdesc = { say( self.mycolor ); " button"; }
    ldesc =
    {
        if ( telescope.telepos=self.mypos and
          fuse.location = powerCompartment and
          telepower.isplugged )
        {
            "The "; say( self.mycolor ); " button is glowing. ";
        }
        else
        {
            "It looks like an ordinary "; say( self.mycolor );
            " button to me. ";
        }
    }
    doPush( actor ) =
    {
        local dropCount, itemRem, thisItem, thisLoc;

        if ( fuse.location = powerCompartment and
          telepower.isplugged )
        {
            "The telescope's motor clicks and whirs for a moment.
            Suddenly, the telescope starts swinging ";
            if ( Me.location <> teleChair )
            {
                "wildly about the room.
                You try to duck out of the way, but it swings
                directly into your forehead, knocking you flat on
                your back. Your head throbs for a few moments. It
                takes more than a few moments for you to regain
                your senses. ";

                if ( dropAll( Me ) > 0 )
                    "You notice that you've dropped everything. ";
                "Meanwhile, the telescope has screeched to a halt,
                possibly rendering the area safe once again. ";
            }
            else if ( actor.isCarrying( powerSupply ))
            {
                "to a different position.
                As the telescope starts to pick up speed, you notice
                the power cord pulling taught. Before you can
                do anything, the cord pulls itself out of the
                power supply with a huge shower of sparks.
                The telescope, rendered powerless, stops moving. ";
                telepower.pluggedobj := nil;
                telepower.isplugged := nil;
                telepower.isShorted := true;
                receptacle.contents := [];
            }
            else if ( not teleBelt.isfastened )
            {
                "wildly about the room,
                taking the control seat with it. You try
                desperately to hang on, but to no avail; the
                wild flailings of the chair finally toss you
                on a long arc, out of the seat, through the doorway,
                landing with a thud in the main room. Your momentum
                carries you, head over heals, clear through the main room
                and out into the dock. ";
                itemRem := Me.contents;
                dropCount := 0;
                while (car( itemRem ))
                {
                    thisItem := car( itemRem );
                    if ( not thisItem.isworn )
                    {
                        dropCount := dropCount + 1;
                        if ( dropCount < 2 ) thisLoc := stationTel;
                        else if ( dropCount < 4 ) thisLoc := stationMain;
                        else if ( dropCount < 6 ) thisLoc := stationComp;
                        else thisLoc := stationDock;
                        thisItem.moveInto( thisLoc );
                    }
                    itemRem := cdr( itemRem );
                }
                if ( dropCount > 0 )
                    "Needless to say, you dropped everything you were
                    carrying along the way. ";
                actor.location := stationDock;
            }
            else
            {
                "wildly about the room,
                taking the control
                seat (and you) with it. After a few terrifying
                moments, the telescope screeches to a halt. ";
                telescope.telepos := self.mypos;
                telescope.telecolor := self.mycolor;
            }
        }
        else
            "\"Click.\"";
    }
;
teleChair: chairitem
    noun = ['chair' 'seat']
    sdesc = "seat"
    location = stationTel
    reachable = { return( self.location.contents ); }
    ldesc =
    {
        "The seat is actually part of the telescope,
        and is positioned at the point of ideal viewing. It looks
        as though it will move with the telescope when the telescope
        is repositioned. There's a seatbelt in the seat, which is,
        at this moment, ";
        if ( teleBelt.isfastened )
            "fastened";
        else
            "unfastened";
        ". ";
    }
;
teleBelt: seatbeltitem
    location = teleChair
    noun = ['belt' 'seatbelt']
    adjective = ['seat']
;
greenbutton: telebuttonsc
    adjective = ['green']
    mycolor = 'green'
    mypos = 1
;
bluebutton: telebuttonsc
    adjective = ['blue']
    mycolor = 'blue'
    mypos = 2
;
yellowbutton: telebuttonsc
    adjective = ['yellow']
    mycolor = 'yellow'
    mypos = 3
;
orangebutton: telebuttonsc
    adjective = ['orange']
    adesc = "an orange button"
    mycolor = 'orange'
    mypos = 4
;
violetbutton: telebuttonsc
    adjective = ['violet']
    mycolor = 'violet'
    mypos = 5
;
redtelebutton: telebuttonsc
    adjective = ['red']
    mycolor = 'red'
    mypos = 0
;
badbulb: bulbitem
    noun = ['bulb' 'glowmaster']
    adjective = 'light' 'burned-out' 'bad'
    sdesc = "burned-out bulb"
    ldesc = "It's a GlowMaster 2000 (tm), but it won't be doing much more
        glowing, due to its broken filament. "
    location = suitSocket
;
suitButton: buttonitem
    adjective = 'white'
    sdesc = "white button"
    location = spacesuit
    doPush( actor ) =
    {
        spacesuit.islighton := not spacesuit.islighton;
        if ( goodbulb.location = suitSocket )
        {
            if ( spacesuit.islighton )
                "The spacesuit's headlamp goes on, emitting its
                full 200 Watt glow. ";
            else
                "The spacesuit's headlamp goes dark. ";
        }
        else "\"Click.\" ";
    }
;
airknob: fixeditem
    noun = ['knob']
    adjective = ['metal' 'small']
    location = stationLab
    sdesc = "knob"
    verDoTurn( actor ) = {}
    doTurn( actor ) =
    {
        if ( not ( airCord.isplugged and
          fuse.location = powerCompartment ))
            "Nothing happens. As you release the knob,
            it springs back to its original position. ";
        else if ( airhose.attachment = suitTank )
        {
            if ( suitTank.isfull )
            {
                "Nothing happens. As you release the knob,
                it springs back to its original position. ";
            }
            else
            {
                "You hear a muted hissing sound from the
                hose. This continues for a few moments,
                then slows, and finally stops. As you release
                the knob, it springs back to its off position. ";
                suitTank.isfull := true;
                incscore( 3 );
            }
        }
        else
            "The plastic hose jumps to life with a loud
            hissing sound and a blast of cold air, all of
            which ceases when you release the knob and it
            springs back to its off position. ";
    }
;
airCord: plugitem
    location = stationLab
    sdesc = "cord"
    noun = ['cord' 'plug']
    adjective = ['power']
;
tramTape: tapeitem
    noun = ['square' 'tape']
    adjective = ['red' 'plastic']
    plural = ['squares' 'tapes']
    sdesc = "square of red plastic"
    ldesc = "It's a red piece of plastic, square, roughly
        an eighth inch thick and three inches on a side. "
    location = stationConPanel
    tramdest = 7992
;
tramScreen: fixeditem
    location = tramShip
    noun = ['screen' 'display']
    adjective = ['display' 'small' 'console']
    sdesc = "display"
    ldesc =
    {
        "The screen is "; self.dispdesc; ". ";
    }
    dispdesc =
    {
        if (car( tramCompartment.contents ) <> fuse )
        {
            if ( tramCord.pluggedobj = receptacle and
              fuse.location = powerCompartment )
                "displaying \"High Probability of External
                Fuse Malfunction\"";
            else
                "blank";
        }
        else
        {
            "displaying \"";
            if (car( tramSlot.contents ))
            {
                if (car( tramSlot.contents ).tramdest ) "Ready";
                else "General failure reading destination tape";
            }
            else "Not ready error reading destination tape";
            "\"";
        }
    }
    verDoRead( actor ) = {}
    doRead( actor ) = { self.dispdesc; }
;
tramSlot: tapeSlotItem
    noun = ['slot']
    location = tramShip
    isqcontainer = true
;
tramConsole: fixeditem
    location = tramShip
    noun = 'console' 'panel'
    adjective = ['control']
    sdesc = "console"
    ldesc =
    {
        "The control panel consists of a small slot, which ";
        if (car( tramSlot.contents ))
        {
            "contains "; car( tramSlot.contents ).adesc;
        }
        else "is empty";
        ", a button labelled \"Launch\", and a small
        display screen, which is "; tramScreen.dispdesc;
        ". A short power cord";
        if ( tramCord.isplugged )
        {
            ", which is plugged into ";
            tramCord.pluggedobj.adesc; ",";
        }
        " emerges from the console beneath a small sign reading
        \"Diagnostic System Power\". ";
    }
;
launchButton: buttonitem
    location = tramShip
    adjective = ['launch']
    sdesc = "launch button"
    ldesc = "It's a big button labelled \"Launch\". "
    doPush( actor ) =
    {
        if (car( tramCompartment.contents ) <> fuse or
          car( tramSlot.contents ) = nil or
          ( tramShip.launchState<>0 and tramShip.launchState<>7 ))
            "\"Click.\" ";
        else if (car( tramSlot.contents ).tramdest = nil )
            "\"Click.\" ";
        else
        {
            local d;

            d := car( tramSlot.contents ).tramdest;

            tramHatch.isopen := nil;
            "The hatch slides shut and latches. ";
            if ( tramShip.launchState = 0 )
            {
                if ( d = global.stationCoord )
                {
                    "It immediately reopens. ";
                    tramHatch.isopen := true;
                }
                else
                {
                    "With a lurch, the tram separates from the
                    station and floats slowly away. ";
                    if ( d = global.planetCoord )
                    {
                        tramShip.launchState := 1;
                        setdaemon( tram2Planet, nil );
                        remfuse( stationShake, nil );
                    }
                    else
                    {
                        tramShip.launchState := 101;
                        setdaemon( tram2Hell, nil );
                    }
                }
            }
            else
            {
                if ( d = global.planetCoord )
                {
                    "It immediately reopens. ";
                    tramHatch.isopen := true;
                }
                else
                {
                    "The console beeps several times. The hatch
                    reopens. ";
                    tramHatch.isopen := true;
/*
                    "The engines start with a roar, sending
                    the tram soaring into the air. ";
                    if (( actor.location = tramPilotSeat ) or
                        ( actor.location = tramPassengerSeat ))
                    {
                        "You are pressed deep into ";
                        actor.location.thedesc; ". ";
                    }
                    else
                    {
                        "Not having had the sense to sit down
                        before firing the rockets, you quite
                        understandably have your face pressed
                        against the floor, not entirely of your
                        own free will.  After what seems like an
                        eternity, the rockets
                        ease up, and you are able to move again.";
                        theFloor.sitloc := actor.location;
                        actor.location := theFloor;
                    }
                    tramShip.launchState := tramShip.launchState + 1;
                    setdaemon( tram2Station, nil );
*/
                }
            }
        }
    }
;
tramPilotSeat: chairitem
    noun = ['chair' 'seat']
    adjective = ['pilot' 'pilot\'s' 'flight']
    plural = ['seats']
    sdesc = "pilot's seat"
    location = tramShip
    reachable = { return( self.location.contents ); }
    ldesc =
    {
        "It looks like an ordinary flight seat to me.
        There is a seatbelt in the seat, which is
        currently ";
        if ( tramPilotBelt.isfastened )
            "fastened";
        else
            "unfastened";
        ". ";
    }
;
tramPassengerSeat: chairitem
    noun = ['chair' 'seat']
    adjective = ['passenger' 'passenger\'s' 'flight']
    plural = ['seats']
    sdesc = "passenger's seat"
    location = tramShip
    reachable = { return( self.location.contents
                          - launchButton
                          - tramSlot ); }
    ldesc =
    {
        "It looks like an ordinary flight seat to me.
        There is a seatbelt in the seat, which is currently ";
        if ( tramPassenerBelt.isfastened )
            "fastened";
        else
            "unfastened";
        ". ";
    }
;
tramPilotBelt: seatbeltitem
    location = tramPilotSeat
    noun = ['belt' 'seatbelt']
    adjective = ['pilot\'s' 'pilot' 'seat']
    sdesc = "pilot's seatbelt"
    plural = ['belts']
;
tramPassenerBelt: seatbeltitem
    location = tramPassengerSeat
    noun = ['belt' 'seatbelt']
    adjective = ['passenger' 'passenger\'s' 'seat']
    sdesc = "passenger's seatbelt"
    plural = ['belts']
;
writerSlot: tapeSlotItem
    location = stationComp
    noun = ['slot']
;
writerCord: plugitem
    location = stationComp
    noun = ['cord' 'plug']
    adjective = ['power']
    sdesc = "cord"
    ldesc =
    {
        "It looks like a normal power cord. ";
        if ( self.isplugged )
        {
            "It's plugged into "; self.pluggedobj.adesc; ". ";
        }
        else "It ends in a standard power plug. ";
    }
;
writerConsole: fixeditem
    location = stationComp
    noun = 'console' 'panel'
    adjective = ['control']
    sdesc = "console"
    ldesc =
    {
        "The console has a numeric keypad with digits 0-9,
        a screen, which is "; writerScreen.dispdesc;
        ", a slot (which ";
        if (car( writerSlot.contents ))
        {
            "contains "; car( writerSlot.contents ).adesc;
        }
        else "is empty";
        "), and a cord";
        if ( writerCord.isplugged )
        {
            ", which is plugged into ";
            writerCord.pluggedobj.adesc;
        }
        ". ";
    }
;
writerScreen: fixeditem
    location = stationComp
    noun = ['screen']
    sdesc = "screen"
    ldesc =
    {
        "The screen is "; self.dispdesc; ". ";
    }
    dispdesc =
    {
        if ( writerCord.isplugged and
          fuse.location = powerCompartment )
        {
            "displaying \"";
            if (car( writerSlot.contents ) = logTape )
                "Write Protect Error";
            else if (car( writerSlot.contents ) = tramTape )
            {
                if (car( writerSlot.contents ).tramdest )
                {
                    "Current value: ";
                    say(car( writerSlot.contents ).tramdest );
                    " - ";
                }
                "Ready for new value";
            }
            else "Not Ready Error";
            "\"";
        }
        else "blank";
    }
;
writerKeypad: fixeditem
    location = stationComp
    noun = ['pad' 'keypad']
    adjective = ['numeric']
    sdesc = "keypad"
    ldesc = "It's a standard numeric keypad, with buttons
        for each of the digits 0-9. "
    verIoTypeOn( actor ) = {}
    ioTypeOn( actor, dobj ) =
    {
        if ( dobj <> numObj )
        {
            "I don't know how to type that on "; self.adesc; ". ";
        }
        else
        {
            if ( writerCord.isplugged and
              fuse.location = powerCompartment and
              tramTape.location = writerSlot )
            {
                tramTape.tramdest := numObj.value;
                "The screen is now "; writerScreen.dispdesc;
                ". ";
            }
            else
            {
                local i;
                i := numObj.value;
                "\"";
                "Tap.";
                i := i/10;
                while ( i )
                {
                    " Tap.";
                    i := i/10;
                }
                "\" ";
            }
        }
    }
;
stationChair: chairitem
    noun = ['chair']
    sdesc = "chair"
    location = stationMain
    isqsurface = true
    reachable = { return( self.contents ); }
    ldesc =
    {
        if ( bottomCushion.location = self )
        {
            "The chair looks quite comfortable, if not all that
            pretty: its bottom cushion is a rather garish floral
            pattern, but its back cushion is diagonally striped
            with red, purple, and green lines of seemingly random
            width. ";
        }
        else
        {
            "The chair doesn't look all that comfortable, since
            it doesn't have a cushion on it. ";
            if ( stationKey.location = self )
            {
                "However, "; stationKey.adesc; " is sitting on
                it. ";
            }
        }
    }
    verIoPutOn( actor ) = {}
    ioPutOn( actor, dobj ) =
    {
        if ( dobj = bottomCushion ) dobj.doPutOn( actor, self );
        else "That really won't get us anywhere. ";
    }
    doSiton( actor ) =
    {
        if ( actor.location <> self )
        {
            if ( stationKey.location = magicChairContainer )
                "As you sit in the apparently comfortable chair, you are
                poked by some sharp metal object under the cushion. ";
            else
                "Okay, you're sitting in the chair now. ";
            actor.moveInto( self );
        }
    }
    verDoSearch( actor ) =
    {
        "Be more specific. ";
    }
;
bottomCushion: item
    isListed = { return( self.location <> stationChair ); }
    notakeall = true   // don't include in "take all" originally
    bulk = 3
    noun = ['cushion']
    adjective = ['bottom' 'seat' 'chair']
    sdesc = "bottom cushion"
    location = stationChair
    ldesc = "The cushion has a striking floral pattern on it. "
    hasScored = nil
    doTake( actor ) =
    {
        self.notakeall := nil;              // can be in 'take all' from now on
        if ( stationKey.location = magicChairContainer )
        {
            "Removing the cushion reveals a shiny metal key! ";
            stationKey.moveInto( stationChair );
            self.moveInto( actor );
            if ( not self.hasScored )
            {
                self.hasScored := true;
                incscore( 4 );
            }
        }
        else pass doTake;
    }
    verDoLookunder( actor ) = {}
    doLookunder( actor ) =
    {
        if ( stationKey.location = magicChairContainer )
        {
            "Under the cushion you find a shiny metal key,
            which you take. ";
            stationKey.moveInto( actor );
            if ( not self.hasScored )
            {
                self.hasScored := true;
                incscore( 4 );
            }
        }
        else "There's nothing there. ";
    }
    doPutOn( actor, io ) =
    {
        if ( io = stationChair and self.location <> stationChair
         and stationKey.location = stationChair )
        {
            stationKey.moveInto( magicChairContainer );
        }
        pass doPutOn;
    }
;
stationKey: item
    location = magicChairContainer
    noun = ['key']
    adjective = ['shiny' 'metal']
    sdesc = "shiny metal key"
    verIoUnlockWith( actor ) = {}
    ioUnlockWith( actor, dobj ) =
    {
        dobj.doUnlockWith( actor, self );
    }
    ioLockWith( actor, dobj ) =
    {
        dobj.doLockWith( actor, self );
    }
;
magicChairContainer: object
//  This is a magic place to put objects lost under the
//  cushion.
;
stationCouch: beditem
    noun = ['couch']
    sdesc = "couch"
    location = stationMain
    ischair = nil
    isbed = true
    ldesc =
    {
        if (itemcnt( self.contents ))
        {
            "On the couch you see "; listcont( self ); ". ";
        }
        else "It looks like an ordinary couch to me. ";
    }
;
backCushion: fixeditem
    noun = ['cushion']
    adjective = ['back']
    sdesc = "back cushion"
    location = stationChair
    ldesc = "It has lots of diagonal stripes:  red, purple,
        green, the colors boggle the mind. "
;
stationDesk1: surface, fixeditem
    sdesc = "desk"
    location = stationBed1
    noun = ['desk']
    ldesc =
    {
        "The desk has a drawer, which is ";
        if ( stationDrawer1.isopen ) "open"; else "closed";
        ". ";
        if (itemcnt( self.contents ))
        {
            "On the desk, you see "; listcont( self ); ". ";
        }
    }
;
stationDrawer1: draweritem
    location = stationBed1
    doLockWith( actor, io ) =
    {
        if ( io <> stationKey )
        {
            caps(); io.thedesc; " doesn't fit the lock. ";
        }
        else
        {
            self.islocked := true;
            "The lock clicks into place. ";
        }
    }
    doUnlockWith( actor, io ) =
    {
        if ( io <> stationKey )
        {
            caps(); io.thedesc; " doesn't fit the lock. ";
        }
        else
        {
            self.islocked := nil;
            "The lock clicks open. ";
        }
    }
;
class draweritem: lockable, fixeditem
    isopen = nil
    islocked = true
    noun = ['drawer']
    sdesc = "drawer"
    ldesc =
    {
        "In the center of the drawer is a small keyhole. ";
        pass ldesc;
    }
    verDoLock( actor ) =
    {
        askio( withPrep );
    }
    verDoUnlock( actor ) =
    {
        askio( withPrep );
    }
    verDoLockWith( actor, io ) =
    {
        if ( self.islocked ) "It's already locked! ";
        else if ( self.isopen ) "You'll have to close it first. ";
    }
    verDoUnlockWith( actor, io ) =
    {
        if ( not self.islocked ) "It's not locked! ";
    }
;
stationDesk2: surface, fixeditem
    sdesc = "desk"
    location = stationBed2
    noun = ['desk']
    ldesc =
    {
        "The desk has a drawer, which is ";
        if ( stationDrawer2.isopen ) "open"; else "closed";
        ". ";
        if (itemcnt( self.contents ))
        {
            "On the desk, you see "; listcont( self ); ". ";
        }
    }
;
stationDrawer2: draweritem
    islocked = nil
    location = stationBed2
    doLockWith( actor, io ) =
    {
        caps(); io.thedesc; " doesn't fit the lock. ";
    }
    doUnlockWith( actor, io ) =
    {
        caps(); io.thedesc; " doesn't fit the lock. ";
    }
;
diaryTape: tapeitem
    noun = ['square' 'tape']
    adjective = ['blue' 'plastic']
    plural = ['squares' 'tapes']
    logCount = 0
    sdesc = "square of blue plastic"
    ldesc = "It's a square piece of blue plastic about
        three inches on a side and an eigth inch thick. "
    location = stationDrawer1
    logdesc =
    {
        self.logCount := self.logCount + 1;
        if ( self.logCount = 1 )
            "The voice of the woman you spoke to earlier comes
            from the log reader. \"Day 223. I don't know what's
            going on around here, but it seems like everything
            is getting lost. This place only has about a dozen
            rooms and I can't find my hairdrier in any of them.\"";
        else if ( self.logCount = 2 )
            "\"Day 225. I'm sure Pinback is hiding things on me.
            It's the only explanation of how a half-ton maintenance
            robot can disappear on a station this size. He knew I
            was going to have it vacuum today, so he hid it on me.
            That man is getting very weird.\"";
        else if ( self.logCount = 3 )
            "\"Day 226. Okay, so we're all getting a little cabin
            fever here. Pinback says he just took the maintenance
            robot down to the surface to set up the new landing pad.
            I guess I was kind of mean to him about the whole deal.\"";
        else if ( self.logCount = 4 )
            "\"Day 228. The stupid robot isn't back yet. I don't know
            what Pinback's up to, but he's sure not telling me whatever
            it is.\"";
        else if ( self.logCount = 5 )
            "\"Day 229. Half the power supplies in the place just
            up and disappeared last night! Pinback says he doesn't
            have any idea where they went. I can't even use the telescope
            and the log writer at the same time now!\"";
        else if ( self.logCount = 6 )
            "\"Day 230. I think there's only one power supply on board now,
            not counting those that Pinback's hiding wherever he's
            hiding them. I'm keeping this one with me all the time
            from now on. Pinback tried to trick me into giving it
            to him so he could fill the air tanks. He said something
            about going outside to replace the fuse again. Stupid
            thing's blowing every couple of trips down, he claims.\"";
        else if ( self.logCount = 7 )
            "\"Day 230. While Pinback was down on the planet today I searched
            his room to see if I could find any of the stuff I thought
            he'd hidden. I didn't find anything, so I pointed the
            telescope straight down at the landing pad. There he was,
            unloading a big heap of equipment. He's trying to drive
            me crazy, I just know it. He keeps saying these obscure
            things about 'when he's in charge.'\"";
        else if ( self.logCount = 8 )
            "\"Day 232. That maniac Pinback tied me up and drugged me
            for the last two days! I managed to free myself while
            he was down on the surface. I think he's becoming
            dangerous. I've got to do something about it. ";
        else
        {
            "\"Day 232. I think I know what Pinback's doing. He's trying
            to get the old laser cannon on the planet working. Somehow he
            thinks that it will make him powerful. He's started calling
            himself 'Lord Pinback.' The man has seriously lost it.\"
            The log reader pauses for a moment, then rewinds the
            tape to the beginning. ";
            self.logCount := 0;
            if ( not self.hasScored )
            {
                self.hasScored := true;
                incscore( 3 );
            }
        }
    }
;
tramGuide: readable
    noun = ['booklet' 'book' 'manual' 'guide']
    adjective = ['troubleshooting']
    sdesc = "booklet"
    ldesc = "It's a small booklet labelled \"TripMaster 2000(tm)
      Troubleshooting Guide\". "
    readdesc = "TripMaster 2000(tm) Troubleshooting Guide
      \bYour TripMaster 2000(tm) is built to provide many weeks of
      reliable and enjoyable service. However, should a problem occur,
      a factory trained repairman can be dispatched within a few
      months to fix the tram. Before calling for service, however,
      take a few moments to follow the easy steps below to see if
      the difficulty might be your problem.
      \bSymptom...\tWhat to check...
      \bPoor or No Navigation - Have you inserted a destination tape?
        Is the destination tape programmed?
      \bGood Navigation, No Movement - Is the tram fueled? Is the fuel
        in the fuel tank? Have you pushed the launch button?
      \bNo Air - Did you open the hatch in space? Is the viewport
        cracked, or missing?
      \bRockets fire, tram remains docked - Is your space station's
        docking system working?
      \bPassengers are thrown around cabin - Are you sitting in a seat?
        Are the seat belts fastened?
      \bTram doesn't land on correct planet - Is navigation tape
        programmed for correct planet?
      \bNo console display - Do you have a console display (available only
        on TripMaster 2000(tm) models)? Is the fuse (conveniently located
        on the tram roof) burned out?
      \bConsole display hard to read - Is there a thick layer of dust
        on the console display? Are you wearing your glasses? Can you
        read? "
    location = stationDrawer2
;
logReader: fixeditem
    location = stationCon
    noun = ['reader' 'logmaster']
    adjective = ['log']
    sdesc = "log reader"
    ldesc =
    {
        "The LogMaster 2000 (tm) log tape reader is the top of the
        line model. It consists of a small slot, which ";
        if (car( logSlot.contents ))
        {
            "contains "; car( logSlot.contents ).adesc;
        }
        else "is empty";
        ", a button labelled \"Continue\", and
        a short cord";
        if ( logCord.isplugged )
        {
            ", which is plugged into ";
            logCord.pluggedobj.adesc;
        }
        ". ";
    }
    verIoPutIn( actor ) =
    {
        logSlot.verIoPutIn( actor );
    }
    ioPutIn( actor, dobj ) =
    {
        logSlot.ioPutIn( actor, dobj );
    }
;
logSlot: tapeSlotItem
    noun = ['slot']
    location = logReader
;
logCord: plugitem
    location = stationCon
    sdesc = "cord"
    noun = ['cord' 'plug']
    adjective = ['power']
;
logButton: buttonitem
    adjective = ['continue']
    location = logReader
    sdesc = "button"
    ldesc = "The button is labelled \"Continue\". "
    doPush( actor ) =
    {
        if ( logCord.isplugged and fuse.location = powerCompartment
          and car( logSlot.contents )<>nil )
            car( logSlot.contents ).logdesc;
        else
            "Nothing happens. ";
    }
;
stationCompressor: fixeditem
    location = stationBench
    noun = ['machine' 'compressor']
    adjective = ['large' 'air']
    sdesc = "large machine"
    ldesc =
    {
        "The machine's notable features are a plastic hose";
        if ( airhose.attachment )
        {
            ", which is attached to "; airhose.attachment.adesc;
        }
        ", a small metal knob, and a cord";
        if ( airCord.isplugged )
        {
            ", which is plugged into "; airCord.pluggedobj.adesc;
        }
        ". ";
    }
;
class airLockDoor: doorway
    noun = ['door']
    adjective = ['air' 'airlock' 'lock']
    doOpen( actor ) =
    {
        "A savvy spacefarer such as yourself quickly
        realizes that you must use the airlock controls
        to operate this door. ";
    }
    doClose( actor ) = { self.doOpen( actor ); }
    isopen = true
;
innerAirDoor: airLockDoor
    sdesc = "inner door"
    ldesc =
    {
        "It's ";
        if ( stationAir.iscycled ) "closed"; else "open"; ". ";
    }
    location = stationAir
    adjective = ['inner']
    isopen = { return( not stationAir.iscycled ); }
;
outerAirDoor: airLockDoor
    sdesc = "outer door"
    ldesc =
    {
        "It's ";
        if ( stationAir.iscycled ) "open"; else "closed"; ". ";
    }
    location = stationAir
    adjective = ['outer']
    isopen = { return( stationAir.iscycled ); }
;
outsideDoor: airLockDoor
    adjective = ['outer']
    sdesc = "outer door"
    ldesc = "It's open. "
    location = stationEva1
;
insideDoor: airLockDoor
    adjective = ['inner']
    sdesc = "inner door"
    ldesc = "It's open. "
    location = stationAir1
;
shipHatch2: doorway
    doOpen( actor ) =
    {
        "Just in the nick of time, you recall that this
        hatch can only be operated from inside the ship. ";
    }
    doClose( actor ) = { self.doOpen( actor ); }
    noun = ['hatch' 'hatchmaster']
    sdesc = "hatch"
    ldesc = "The hatch is open. "
    location = airLock2
    isopen = true
;
stationConWindow: fixeditem
    sdesc = "window"
    noun = ['window']
    adjective = ['large' 'picture']
    ldesc = "Through the window you can see a breathtaking
        view of the planet above. "
    thrudesc = { self.ldesc; }
    location = stationCon
    verDoLookthru( actor ) = {}
    doLookthru( actor ) = { self.thrudesc; }
;
stationConScreen: fixeditem
    noun = ['screen' 'display']
    adjective = ['display']
    sdesc = "screen"
    ldesc = "The screen is displaying \"Bad command or file
        name\". "
    location = stationCon
;
stationConKeyboard: fixeditem
    noun = ['keyboard']
    adjective = ['standard' 'computer']
    sdesc = "computer keyboard"
    location = stationCon
    verIoTypeOn( actor ) = {}
    ioTypeOn( actor, dobj ) =
    {
        if ( dobj = numObj or dobj = strObj )
            "The screen blanks, flashes for a moment,
            then displays \"Bad command or file name\". ";
        else "I don't know how to type that. ";
    }
;
stationBed2Bed: beditem
    noun = ['bed']
    location = stationBed2
    reachable = [stationBed2Bed]
;
stationBed1Bed: beditem
    noun = ['bed']
    location = stationBed1
    reachable = [stationBed1Bed]
;
air3Hatch: doorway
    isopen = true
    doOpen( actor ) =
    {
        "The hatch is controlled automatically by the ship docked
        to this airlock. ";
    }
    doClose( actor ) = { self.doOpen( actor ); }
    noun = ['hatch']
    sdesc = "hatch"
    ldesc = "The hatch is open. "
    location = airLock3
;
air1Hatch: doorway
    isopen = nil
    doOpen( actor ) =
    {
        "This door cannot be opened except when a spaceship is
        docked to this airlock. ";
    }
    doClose( actor ) = { self.doOpen( actor ); }
    noun = ['hatch']
    sdesc = "hatch"
    ldesc = "The hatch is closed. "
    location = airLock1
;
indicator2: fixeditem
    noun = ['light']
    adjective = ['green' 'indicator']
    sdesc = "indicator light"
    ldesc = "The indicator light is glowing green. "
    location = airLock2
;
indicator3: fixeditem
    noun = ['light']
    adjective = ['green' 'indicator']
    sdesc = "indicator light"
    ldesc = "The indicator light is glowing green. "
    location = airLock3
;
indicator1: fixeditem
    noun = ['light']
    adjective = ['red' 'indicator']
    sdesc = "indicator light"
    ldesc = "The indicator light is glowing red. "
    location = airLock1
;
tramViewport: fixeditem
    location = tramShip
    sdesc = "viewport"
    noun = ['viewport' 'port' 'window']
    adjective = ['view']
    ldesc =
    {
        local s;

        s := tramShip.launchState;
        if ( s = 0 )
            "Through the viewport you see some stars. The upper
            half of your view is obstructed by the huge farm of
            solar collectors floating above the station. ";
        /*
         *   The ride down
         */
        else if ( s = 1 or s = 2 )
            "You see the space station floating nearby, slowly
            receeding into the distance. The planet hangs above. ";
        else if ( s = 3 )
            "The planet is rapidly approaching. In
            the distance, the remnants of the space station can
            be seen entering the atmosphere, bursting into
            spectacular balls of fire as they fall toward the
            planet. ";
        else if ( s = 4 )
            "All you can see is the red glow of the heat of
            re-entry. ";
        else if ( s = 5 )
            "The planet's surface is just below. There seems to
            be a complex of some sort below you. ";
        else if ( s = 6 or s = 7 )
            "You see the landing pad. ";
        /*
         *   Launching again
         */
/*
        else if ( s = 8 )
            "You see mostly the sky. ";
        else if ( s = 9 )
            "The atmosphere is getting thin. ";
        else if ( s = 10 )
            "In space, approaching space station. ";
        else if ( s = 11 )
            "Drifting. ";
        else if ( s = 12 )
            "About to dock. ";
*/
        /*
         *   Tram to Hell
         */
        else if ( s > 99 )
            "You see mostly stars. The space station is rapidly
            shrinking in the distance. ";
    }
    thrudesc = { self.ldesc; }
    verDoLookthru( actor ) = {}
    doLookthru( actor ) = { self.thrudesc; }
;
bolognaSandwich: fooditem
    noun = ['sandwich']
    plural = ['sandwiches']
    adjective = ['bologna']
    sdesc = "bologna sandwich"
    ldesc = "It looks like a bologna sandwich, but it smells like a ham
        sandwich.  Despite that, it looks edible enough. "
    location = fridge
;
hamSandwich: fooditem
    noun = ['sandwich']
    plural = ['sandwiches']
    adjective = ['ham']
    sdesc = "ham sandwich"
    ldesc = "It looks like a ham sandwich, but it smells like a bologna
        sandwich.  Despite that, it looks edible enough. "
    location = fridge
;
stationKitchenShelves: surface, fixeditem
    sdesc = "set of shelves"
    noun = ['shelf']
    plural = ['shelves']
    adjective = ['plastic']
    location = stationKitchen
    ldesc =
    {
        if ( itemcnt( self.contents ))
        {
            "On the shelves you see "; listcont( self ); ". ";
        }
        else "It looks like an ordinary set of shelves to me. ";
    }
;
stationToilet: decoration
    sdesc = "toilet"
    noun = ['toilet' 'john' 'jon']
    location = stationLav
;
stationSink: decoration
    sdesc = "sink"
    noun = ['sink']
    location = stationLav
;
station3V: decoration
    noun = ['tri-v']
    location = stationMain
    sdesc = "tri-V"
    ldesc = "You see that this is a ordinary VuMaster 2000 (tm)
        3-D imaging television, the top of line model. It is
        currently off."
;
shipConsole: fixeditem
    noun = ['console']
    sdesc = "console"
    ldesc =
    {
        "The console consists of a vast array of
        controls, but the only ones which interest you
        are the buttons labelled \"Distress\" and \"AutoNav\",
        as these are the ones that can get you out of the
        worst situations. You also notice a button labelled
        \"Launch\", a fuel cell socket";
        if (car( startFuelSocket.contents ))
        {
            " (which contains ";
            car( startFuelSocket.contents ).adesc; ")";
        }
        " with a button next to it labelled \"Eject\", and
        a small slot";
        if (car( startSlot.contents ))
        {
            " (which contains ";
            car( startSlot.contents ).adesc; ")";
        }
        ". ";
    }
    location = startroom
;
startFuelSocket: qcontainer, fixeditem
    noun = ['socket']
    adjective = ['fuel' 'cell']
    sdesc = "fuel cell socket"
    location = startroom
    ioPutIn( actor, dobj ) =
    {
        if (car( self.contents ))
        {
            "You can only put one object in "; self.thedesc; " at a time. ";
        }
        else if ( not dobj.isfuelcell )
        {
            caps(); dobj.thedesc; " won't fit in "; self.thedesc; ". ";
        }
        else dobj.doPutIn( actor, self );
    }
;
startSlot: tapeSlotItem
    noun = 'slot'
    location = startroom
    isqcontainer = true
;
distressButton: buttonitem
    location = startroom
    adjective = 'distress'
    sdesc = "distress button"
    doPush( actor ) =
    {
        if ( self.isused )
            "As with elevators and \"push for walk signal\"
            buttons, it doesn't help to push it over and
            over. ";
        else
        {
            self.isused := true;
            "A tinny metallic voice announces, \"Distress
            signal activated. Stand by.\"";
            setfuse( distressCall, 4, nil );
        }
    }
;
startFuelCell: item
    noun = 'cell'
    adjective = 'empty' 'fuel'
    sdesc = "empty fuel cell"
    adesc = "an empty fuel cell"
    ldesc = "It's a FuelMaster 2000(tm), the top of the line
        model.  It looks empty. "
    location = startFuelSocket
    isfuelcell = true
    verDoTake( actor ) =
    {
        if ( self.location = startFuelSocket )
        {
            "It is securely locked in the socket. ";
        }
        else pass verDoTake;
    }
;
ejectButton: buttonitem
    location = startroom
    adjective = 'eject'
    sdesc = "eject button"
    doPush( actor ) =
    {
        if ( not startroom.isdocked )
            "The computer announces, \"fuel cell is interlocked
            while in flight.\"";
        else if (car( startFuelSocket.contents ))
        {
            "Three short beeps sound from the console, then there
            is some clicking and whirring, then, without warning,
            the fuel cell pops out of the console, arcs across
            the cockpit, and lands on the floor. ";
            car( startFuelSocket.contents ).moveInto( startroom );
        }
        else "\"Click.\"";
    }
;
fuelCellBox: container
    noun = 'box'
    adjective = 'fuel' 'cell' 'cells'
    sdesc = "fuel cell box"
    weight = 1
    bulk = 2
    ldesc =
    {
        "It's labelled \"FuelMaster 2000(tm) Fuel Cells
        (20 pieces)\". ";
        if (itemcnt( self.contents ))
        {
            "The box contains "; listcont( self ); ". ";
        }
	else "It's empty. ";
    }
    location = stationDock
;
shipLaunchButton: buttonitem
    location = startroom
    adjective = 'launch'
    sdesc = "launch button"
    doPush( actor ) =
    {
        "\"Click.\"";
    }
;
startTape: tapeitem
    noun = 'square' 'tape'
    adjective = 'gray' 'grey' 'plastic'
    plural = 'squares' 'tapes'
    sdesc = "square of gray plastic"
    ldesc = "It's a gray square of plastic, roughly an eighth
        of an inch thick, and three inches on a side. "
    location = startSlot
;
swampPlantWord: fixeditem, floatingItem
    noun = ['plant']
    sdesc = "plant"
    location =
    {
        if ( Me.location.isSwampRoom ) return( Me.location );
        else return( nil );
    }
    locationOK = true  // suppress warning about location being a method
    doInspect( actor ) = { actor.location.myplant.doInspect( actor ); }
    verDoLookin( actor ) = {}
    doLookin( actor ) = { actor.location.myplant.doLookin( actor ); }
;
class swampSpotWord: fixeditem
    noun = ['spot']
    verDoTouch( actor ) = {}
    verDoPoke( actor ) = {}
    verDoPush( actor ) = {}
    doTouch( actor ) = { self.doPush( actor ); }
    doPoke( actor ) = { self.doPush( actor ); }
;
redSwampSpotWord: swampSpotWord, floatingItem
    adjective = ['red']
    sdesc = "red spot"
    location =
    {
        if ( Me.location.isSwampRoom ) return( Me.location );
        else return( nil );
    }
    locationOK = true  // suppress warning about location being a method
    doPush( actor ) = { actor.location.myplant.myredspot.doPush( actor ); }
;
blueSwampSpotWord: swampSpotWord, floatingItem
    adjective = ['blue']
    sdesc = "blue spot"
    location =
    {
        if ( Me.location.isSwampRoom )
        {
            if ( Me.location.myplant.isPlant2 ) return( Me.location );
            else return( nil );
        }
        else return( nil );
    }
    locationOK = true   // suppress warning about location being a method
    doPush( actor ) = { actor.location.myplant.mybluespot.doPush( actor ); }
;
magicVerb: deepverb  // for the use of players who have completed part I before
    verb = 'xyzzy'
    action( actor ) =
    {
/*
        self.value := self.value + 1;
        if ( self.value < 3 or tramShip.launchState <> 0 )
*/
            "A hollow voice says \"Fool.\" ";
/*
	else
        {
            "A hollow voice says \"You have now completed part I.\"\b";

            hamSandwich.moveInto( Me );
            bolognaSandwich.moveInto( Me );

            Me.moveInto( tramShip );
            badfuse.moveInto( nil );
            fuse.moveInto( tramCompartment );
            while (car( tramSlot.contents ))
                car( tramSlot.contents ).moveInto( nil );
            tramTape.moveInto( tramSlot );
            tramTape.tramdest := global.planetCoord;
            global.score := 35;

            incscore( 0 );
            launchButton.doPush( actor );
        }
*/
    }
/*
    value = 0
*/
;
vacTape: tapeitem
    noun = 'square' 'tape'
    adjective = 'plastic' 'orange'
    plural = 'squares' 'tapes'
    sdesc = "orange square"
    adesc = "an orange square"
    ldesc = "It's a small orange square of plastic, about
        three inches on a side and an eighth of an inch thick. "
    location = vacRobotSlot
;
remoteControl: item
    noun = 'control'
    adjective = 'remote'
    sdesc = "remote control"
    ldesc = "It's a small remote, the kind usually used to
        control such common household appliances as HyperWave
        Ovens and Tri-V's, except that this one has but one
        copper touch pad and is completely unlabelled. "
    location = stationCouch
;
shuttlePanel: fixeditem
    location = shuttle
    noun = 'panel' 'console'
    adjective = 'control'
    sdesc = "control panel"
    ldesc =
    {
        "The control panel consists of a joystick, a
        silver touch pad labelled \"Go,\" and a dial.  The dial
        has several positions, numbered 1 to << shuttleDial.maxsetting >>;
        it is currently in position << shuttleDial.setting >>.
        A small annunciator light labelled \"Autopilot Engaged\" is
        currently << autopilotSwitch.isOn ? "lit" : "off" >>. ";
        if ( not canopy.isblown )
            "In addition, off to one side of the panel is a large red
            ripcord, labelled \"Emergency Canopy Release.\"";
    }
;
shuttleDial: fixeditem
    location = shuttle
    noun = 'dial'
    sdesc = "dial"
    ldesc = "The dial can be set to positions numbered
      from 1 to << say( self.maxsetting ) >>; it is currently
      turned to position << say( self.setting ) >>. "
    setting = 1
    maxsetting = (length( shuttle.destlist ))
    verDoMoveTo( actor, io ) = { self.verDoTurnTo( actor, io ); }
    doMoveTo( actor, io ) = { self.doTurnTo( actor, io ); }
    verDoTurnTo( actor, io ) =
    {
        if ( io <> numObj ) "I don't know how to turn the dial to that. ";
    }
    doTurnTo( actor, io ) =
    {
        if ( numObj.value < 1 or numObj.value > self.maxsetting )
            "The dial doesn't have any such setting. ";
        else if ( numObj.value = self.setting )
        {
            "The dial is already set to << numObj.value >>! ";
        }
        else
        {
            "Okay, the dial is now set to position << numObj.value >>. ";
            self.setting := numObj.value;
        }
    }
;
touchPad: fixeditem
    location = shuttle
    sdesc = "silver pad"
    noun = ['pad']
    adjective = 'silver'
    verDoTouch( actor ) = {}
    doTouch( actor ) =
    {
        if ( shuttle.inRem<>0 or shuttle.outRem<>0 or
         shuttle.location=centralHub )
            "Nothing happens. ";
        else
        {
            if ( autopilotSwitch.isOn )
            {
                shuttle.autoDest := shuttle.destlist[shuttleDial.setting];
                if ( shuttle.autoDest = shuttle.location )
                {
                    "A pleasant female computer-generated voice
                    announces from
                    a hidden speaker: \"*BING* You are already at
                    your selected destination.  Please select a
                    different destination.\"";
                    return;
                }
            }
            else
                shuttle.autoDest := nil;

            if ( not canopy.isblown )
            {
                "The canopy closes, and the";
                canopy.isopen := nil;
            }
            else "The";
            " shuttle speeds off into the tunnel. ";
            setTubeNose( shuttle.location );
            setdaemon( shuttleDaemon, nil );
            shuttle.isActive := true;
            global.sleepList := global.sleepList + shuttle;
        }
    }
;
remotePad: fixeditem
    noun = 'pad' 'touchpad'
    adjective = 'touch' 'copper'
    location = remoteControl
    sdesc = "copper touch pad"
    ldesc = "It's the typical metal pad that's generally
        activated by touching it. You don't remember the details
        of how these devices work, but then, you don't need to
        know much about them to use them. "
    verDoTouch( actor ) = {}
    doTouch( actor ) =
    {
        local meLoc;

        meLoc := Me.location;
        while ( meLoc.location ) meLoc := meLoc.location;

        if ( pyrRobot.location = meLoc )
        {
            pyrRobot.isActive := not pyrRobot.isActive;
            if ( pyrRobot.isActive )
            {
                if (car( pyrRobotSlot.contents ) = vacTape )
                {
                    "The robot powers on and looks around the room. ";
                    if ( pyrRobot.location = vacuumCleaner.location )
                    {
                        vacuumCleaner.moveInto( pyrRobot );
                        "It glides over to the vacuum cleaner and
                        picks it up; the vacuum comes to life with a
                        distracting whine. The robot starts moving
                        through the room, vacuuming and tidying up.
                        After it has dusted everything in sight, it
                        moves off to the west. You hear terrible
                        crashes and explosions and laserblasts and
                        bangs, but you still hear the vacuum cleaner
                        whining annoyingly. Finally, a huge explosion
                        resounds through the chamber, and the vacuuming
                        ceases. ";
                        setfuse( gauntletRobotFuse, 4, nil );
                        pyrRobot.moveInto( nil );
                        pyrRobotRemains.moveInto( gauntlet1 );
                        gauntlet1.isActive := nil;
                        gauntlet1.isPowerless := true;
                    }
                    else
                    {
                        "After a few moments, it appears confused,
                        and shuts itself off. ";
                        pyrRobot.isActive := nil;
                    }
                }
                else if (car( pyrRobotSlot.contents ) = gauntletTape )
                {
                    "The robot powers on and assumes a defensive
                    posture in front of the east passage. ";
                }
                else
                {
                    pyrRobot.isActive := nil;
                    "The robot powers on, looks around as though
                    confused, beeps three times, and shuts itself
                    back off. ";
                }
            }
            else
                "The robot stands perfectly still for a moment,
                then shuts itself down. ";
        }
        else if ( vacRobot.location = meLoc )
        {
            vacRobot.isActive := not vacRobot.isActive;
            if ( vacRobot.isActive )
            {
                "The robot springs to life. ";
                if (car( vacRobotSlot.contents ) = vacTape )
                {
                    if ( vacuumCleaner.location = vacRobot.location )
                    {
                        "It zips over the vacuum cleaner and picks
                        it up. ";
                        vacuumCleaner.moveInto( vacRobot );
                    }
                    if ( vacuumCleaner.location <> vacRobot )
                    {
                        "It looks around for a few moments as though
                        searching for something. After a bit, it gives
                        up, apparently not finding what it was looking
                        for, and shuts itself back down. ";
                        vacRobot.isActive := nil;
                    }
                    else
                    {
                        "It starts dashing around the room, carrying
                        out its program of ceaseless vacuuming and
                        tidying up. ";
                        setdaemon( vacDaemon, nil );
                    }
                }
                else  // wrong tape in slot
                {
                    vacRobot.isActive := nil;
                    "It beeps three times, and shuts itself off again. ";
                }
            }
            else
            {
                "The robot stops dead in its tracks, shuts
                off the vacuum and drops it to the floor. The
                robot then powers down, slumping over
                into an inanimate pile. ";
                vacuumCleaner.moveInto( vacRobot.location );
                remdaemon( vacDaemon, nil );
            }
        }
        else "Nothing seems to happen. ";
    }
;
gauntletTape: tapeitem
    noun = 'square' 'tape'
    adjective = 'plastic' 'black'
    plural = 'squares' 'tapes'
    sdesc = "black square"
    ldesc = "It's a square of black plastic, very much like all
        the other squares of plastic you've run into. "
    location = pyrRobotSlot
;
callButton: buttonitem
    location = controlUnit
    adjective = 'shuttle' 'call'
    sdesc = "shuttle call button"
    doPush( actor ) =
    {
        if ( actor.location = shuttle or
         actor.location = shuttle.location )
            "A pleasant female computer-generated voice
            announces from a hidden speaker: \"*BING* The
            shuttle is already at your location.\"";
        else
        {
            "A pleasant female computer-generated voice
            announces from a hidden speaker: \"*BING The
            shuttle ";
            if ( shuttle.isActive )
                "is already engaged.\"";
            else
            {
                "has been activated.\"";
                if ( actor.location.isdepot )
                    shuttle.autoDest := actor.location;
                else
                    shuttle.autoDesc := shuttle.location;
                setTubeNose( shuttle.location );
                setdaemon( shuttleDaemon, nil );
                shuttle.isActive := true;
            }
        }
    }
;
buttonItem: buttonitem
;
airshaft4: room
    sdesc = "Top of Air Shaft"
    ldesc = "You are at the top of a tall air shaft.
      A ladder leads down into the shaft.  An air
      vent leads south; it looks large enough that
      you can probably fit through it. "
    south = airvent1
    down = airshaft3
;
caveRoom10: caveRoom
    south = caveRoom8
    nw = caveRoom11
    dirdesc = "south and northwest"
;
caveRoom9: caveRoom
    down = caveRoom8
    iscaveledge = true
    dirdesc = "down"
;
caveRoom46: caveRoom
    north = caveRoom47
    south = caveRoom6
    dirdesc = "north and south"
;
caveRoom45: caveRoom
    nw = caveRoom44
    se = caveRoom6
    dirdesc = "northwest and southeast"
;
caveRoom22: caveRoom
    west = caveRoom23
    nw = caveRoom35
    se = caveRoom5
    dirdesc = "west, northwest, and southeast"
;
caveRoom21: caveRoom
    south = caveRoom20
    nw = caveRoom14
    dirdesc = "south and northwest"
;
caveRoom17: caveRoom
    south = caveRoom18
    nw = caveRoom15
    dirdesc = "south and northwest"
;
class airLadder: fixeditem
    noun = ['ladder']
    sdesc = "ladder"
    verDoClimb( actor ) =
    {
        "Do you want to climb up
        or down the ladder? ";
    }
    verDoClimbup( actor ) = {}
    doClimbup( actor ) =
    {
        actor.travelTo( self.location.up );
    }
    verDoClimbdown( actor ) = {}
    doClimbdown( actor ) =
    {
        actor.travelTo( self.location.down );
    }
;
airLadder1: airLadder
    location = airshaft1
    verDoClimb( actor ) = {}
    doClimb( actor ) =
    {
        self.doClimbup( actor );
    }
    verDoClimbdown( actor ) =
    {
        "The ladder only goes up. ";
    }
;
climbupVerb: deepverb
    verb = 'climb up'
    sdesc = "climb up"
    doAction = 'Climbup'
;
climbdownVerb: deepverb
    verb = 'climb down'
    sdesc = "climb down"
    doAction = 'Climbdown'
;
airLadder2: airLadder
    location = airshaft2
;
airLadder3: airLadder
    location = airshaft3
;
airLadder4: airLadder
    location = airshaft4
    verDoClimbup( actor ) =
    {
        "The ladder only goes down. ";
    }
    verDoClimb( actor ) = {}
    doClimb( actor ) =
    {
        self.doClimbdown( actor );
    }
;
ripcord: fixeditem
    location = shuttle
    noun = 'ripcord' 'cord'
    adjective = 'rip'
    sdesc = "ripcord"
    ldesc =
    {
        if ( canopy.isblown )
            "Only the socket which once contained
            the ripcord remains; some evil person has
            already used the emergency canopy release. ";
        else
            "The ripcord is labelled \"Emergency Canopy Release.\"";
    }
    verDoPull( actor ) =
    {
        if ( canopy.isblown ) "The ripcord has already been pulled. ";
    }
    doPull( actor ) =
    {
        "You give the ripcord a good tug, and it comes free of its
        socket.  For a moment you think it might have been defective,
        but suddenly, all around the rim of the canopy, huge explosive
        charges ignite with a deafening roar and a blinding flash
        of light.  The shuttle is momentarily filled with a
        cloud of thick, black, sulfurous smoke.  After a while, the
        smoke dissipates, and you see that the canopy hasn't been
        so much ejected as blown to bits. You wonder for a moment
        how you survived the explosion, much less escaped serious
        injury. ";
        canopy.isblown := true;
    }
;
escapeLaunch: buttonitem
    sdesc = "launch button"
    adjective = 'launch'
    location = escapeShip
    doPush( actor ) =
    {
        if ( zeenite.timer >= 4 )
        {
            "As you start to push the button, Pinback appears at the
            door, carrying a gun. He is furious. \"You have destroyed
            my laser!\" he screams. \"I'll make you pay!\" He raises
            up his gun to point directly at you. Just as he is about
            to squeeze the trigger, an enormous xeno-beaver comes up
            behind him and, seeing the entrance to its nest blocked,
            starts to attack. Pinback shouts in terror,
            and runs off into the swamp.
            \n\tYou push the launch button. ";
        }

        "The ship launches with a roar of powerful rocket
        motors. ";
        escapeShip.isActive := true;
        if ( zeenite.timer < 4 )
        {
            "Unfortunately, you do not get very high before
            the base's laser cannons blast you out of the sky. ";
            die();
            abort;
        }
        setdaemon( escapeDaemon, nil );
    }
;
caveRoom11: caveRoom
    south = caveRoom47
    nw = caveRoom12
    se = caveRoom10
    dirdesc = "south, northwest, and southeast"
;
caveRoom47: caveRoom
    north = caveRoom11
    south = caveRoom46
    west = caveRoom48
    nw = caveRoom50
    dirdesc = "north, south, west, and northwest"
;
caveRoom44: caveRoom
    nw = caveRoom43
    se = caveRoom45
    dirdesc = "northwest and southeast"
;
caveRoom23: caveRoom
    east = caveRoom22
    nw = caveRoom24
    dirdesc = "east and northwest"
;
caveRoom35: caveRoom
    nw = caveRoom36
    se = caveRoom22
    dirdesc = "northwest and southeast"
;
caveRoom14: caveRoom
    east = caveRoom15
    nw = caveRoom13
    se = caveRoom21
    dirdesc = "east, northwest, and southeast"
;
caveRoom15: caveRoom
    west = caveRoom14
    se = caveRoom17
    up = caveRoom16
    dirdesc = "west, southeast, and up"
;
caveRoom12: caveRoom
    east = caveRoom13
    nw = caveRoom55
    se = caveRoom11
    dirdesc = "east, northwest, and southeast"
;
caveRoom48: caveRoom
    east = caveRoom47
    nw = caveRoom49
    dirdesc = "east and northwest"
;
caveRoom50: caveRoom
    west = caveRoom49
    se = caveRoom47
    dirdesc = "west and southeast"
;
caveRoom43: caveRoom
    nw = caveRoom42
    se = caveRoom44
    dirdesc = "northwest and southeast"
;
caveRoom24: caveRoom
    west = caveRoom26
    nw = caveRoom34
    se = caveRoom23
    up = caveRoom25
    dirdesc = "west, northwest, southeast, and up"
;
caveRoom36: caveRoom
    nw = caveRoom37
    se = caveRoom35
    dirdesc = "northwest and southeast"
;
caveRoom13: caveRoom
    west = caveRoom12
    se = caveRoom14
    dirdesc = "west and southeast"
;
caveRoom16: caveRoom
    down = caveRoom15
    iscaveledge = true
    dirdesc = "down"
;
caveRoom49: caveRoom
    north = caveRoom52
    east = caveRoom50
    nw = caveRoom51
    se = caveRoom48
    dirdesc = "north, east, northwest, and southeast"
;
caveRoom42: caveRoom
    west = caveRoom37
    nw = caveRoom41
    se = caveRoom43
    dirdesc = "west, northwest, and southeast"
;
caveRoom26: caveRoom
    east = caveRoom24
    nw = caveRoom27
    dirdesc = "east and northwest"
;
caveRoom34: caveRoom
    nw = caveRoom33
    se = caveRoom24
    dirdesc = "northwest and southeast"
;
caveRoom25: caveRoom
    down = caveRoom24
    iscaveledge = true
    dirdesc = "down"
;
caveRoom37: caveRoom
    east = caveRoom42
    nw = caveRoom32
    se = caveRoom36
    up = caveRoom38
    dirdesc = "east, northwest, southeast, and up"
;
caveRoom27: caveRoom
    nw = caveRoom28
    se = caveRoom26
    dirdesc = "northwest and southeast"
;
caveRoom33: caveRoom
    north = caveRoom32
    se = caveRoom34
    dirdesc = "north and southeast"
;
caveRoom32: caveRoom
    north = caveRoom31
    south = caveRoom33
    se = caveRoom37
    dirdesc = "north, south, and southeast"
;
caveRoom38: caveRoom
    down = caveRoom37
    iscaveledge = true
    dirdesc = "down"
;
caveRoom55: caveRoom
    nw = caveRoom54
    se = caveRoom12
    dirdesc = "northwest and southeast"
;
caveRoom52: caveRoom
    south = caveRoom49
    nw = caveRoom53
    dirdesc = "south and northwest"
;
caveRoom51: caveRoom
    nw = caveRoom56
    se = caveRoom49
    dirdesc = "northwest and southeast"
;
caveRoom41: caveRoom
    north = caveRoom40
    se = caveRoom42
    dirdesc = "north and southeast"
;
caveRoom54: caveRoom
    north = caveRoom58
    south = caveRoom53
    ne = caveRoom70
    se = caveRoom55
    dirdesc = "north, south, northeast, and southeast"
;
caveRoom58: caveRoom
    north = caveRoom60
    south = caveRoom54
    ne = caveRoom62
    sw = caveRoom57
    up = caveRoom59
    dirdesc = "north, south, northeast, southwest, and up"
;
caveRoom53: caveRoom
    north = caveRoom54
    se = caveRoom52
    dirdesc = "north and southeast"
;
caveRoom70: caveRoom
    ne = caveRoom67
    sw = caveRoom54
    dirdesc = "northeast and southwest"
;
caveRoom56: caveRoom
    north = caveRoom57
    nw = caveRoom40
    se = caveRoom51
    dirdesc = "north, northwest, and southeast"
;
caveRoom60: caveRoom
    north = caveRoom61
    south = caveRoom58
    dirdesc = "north and south"
;
caveRoom62: caveRoom
    nw = caveRoom61
    sw = caveRoom58
    dirdesc = "northwest and southwest"
;
caveRoom57: caveRoom
    south = caveRoom56
    ne = caveRoom58
    dirdesc = "south and northeast"
;
caveRoom59: caveRoom
    down = caveRoom58
    iscaveledge = true
    dirdesc = "down"
;
caveRoom67: caveRoom
    north = caveRoom68
    nw = caveRoom66
    sw = caveRoom70
    dirdesc = "north, northwest, and southwest"
;
caveRoom61: caveRoom
    north = caveRoom63
    south = caveRoom60
    se = caveRoom62
    dirdesc = "north, south, and southeast"
;
caveRoom68: caveRoom
    south = caveRoom67
    nw = caveRoom65
    up = caveRoom69
    dirdesc = "south, northwest, and up"
;
caveRoom66: caveRoom
    north = caveRoom65
    se = caveRoom67
    dirdesc = "north and southeast"
;
caveRoom28: caveRoom
    north = caveRoom29
    se = caveRoom27
    dirdesc = "north and southeast"
;
caveRoom31: caveRoom
    north = caveRoom39
    south = caveRoom32
    sw = caveRoom29
    dirdesc = "north, south, and southwest"
;
caveRoom29: caveRoom
    south = caveRoom28
    ne = caveRoom31
    up = caveRoom30
    dirdesc = "south, northeast, and up"
;
caveRoom30: caveRoom
    down = caveRoom29
    iscaveledge = true
    dirdesc = "down"
;
caveRoom39: caveRoom
    south = caveRoom31
    nw = caveRoom85
    se = caveRoom40
    dirdesc = "south, northwest, and southeast"
;
caveRoom85: caveRoom
    north = caveRoom86
    ne = caveRoom84
    se = caveRoom39
    up = caveRoom91
    dirdesc = "north, northeast, southeast, and up"
;
caveRoom40: caveRoom
    south = caveRoom41
    nw = caveRoom39
    se = caveRoom56
    dirdesc = "south, northwest, and southeast"
;
caveRoom86: caveRoom
    north = caveRoom87
    south = caveRoom85
    ne = caveRoom89
    dirdesc = "north, south, and northeast"
;
caveRoom84: caveRoom
    ne = caveRoom83
    sw = caveRoom85
    dirdesc = "northeast and southwest"
;
caveRoom91: caveRoom
    down = caveRoom85
    iscaveledge = true
    dirdesc = "down"
;
caveRoom87: caveRoom
    south = caveRoom86
    ne = caveRoom88
    dirdesc = "south and northeast"
;
caveRoom89: caveRoom
    north = caveRoom88
    sw = caveRoom86
    up = caveRoom90
    dirdesc = "north, southwest, and up"
;
caveRoom83: caveRoom
    north = caveRoom82
    sw = caveRoom84
    dirdesc = "north and southwest"
;
caveRoom88: caveRoom
    south = caveRoom89
    ne = caveRoom81
    sw = caveRoom87
    dirdesc = "south, northeast, and southwest"
;
caveRoom90: caveRoom
    down = caveRoom89
    iscaveledge = true
    dirdesc = "down"
;
caveRoom82: caveRoom
    north = caveRoom81
    south = caveRoom83
    dirdesc = "north and south"
;
caveRoom81: caveRoom
    north = caveRoom80
    south = caveRoom82
    nw = caveRoom92
    sw = caveRoom88
    dirdesc = "north, south, northwest, and southwest"
;
caveRoom63: caveRoom
    south = caveRoom61
    ne = caveRoom64
    dirdesc = "south and northeast"
;
caveRoom65: caveRoom
    north = caveRoom64
    south = caveRoom66
    se = caveRoom68
    dirdesc = "north, south, and southeast"
;
caveRoom69: caveRoom
    down = caveRoom68
    iscaveledge = true
    dirdesc = "down"
;
caveRoom64: caveRoom
    south = caveRoom65
    nw = caveRoom71
    sw = caveRoom63
    dirdesc = "south, northwest, and southwest"
;
caveRoom71: caveRoom
    north = caveRoom79
    nw = caveRoom72
    se = caveRoom64
    dirdesc = "north, northwest, and southeast"
;
caveRoom79: caveRoom
    south = caveRoom71
    nw = caveRoom77
    dirdesc = "south and northwest"
;
caveRoom72: caveRoom
    nw = caveRoom73
    se = caveRoom71
    dirdesc = "northwest and southeast"
;
caveRoom77: caveRoom
    ne = caveRoom76
    se = caveRoom79
    up = caveRoom78
    dirdesc = "northeast, southeast, and up"
;
caveRoom73: caveRoom
    north = caveRoom121
    south = caveRoom80
    ne = caveRoom74
    nw = caveRoom101
    se = caveRoom72
    dirdesc = "north, south, northeast, northwest, and southeast"
;
caveRoom76: caveRoom
    nw = caveRoom75
    sw = caveRoom77
    dirdesc = "northwest and southwest"
;
caveRoom78: caveRoom
    down = caveRoom77
    iscaveledge = true
    dirdesc = "down"
;
caveRoom121: caveRoom
    north = caveRoom120
    south = caveRoom73
    dirdesc = "north and south"
;
caveRoom80: caveRoom
    north = caveRoom73
    south = caveRoom81
    nw = caveRoom100
    dirdesc = "north, south, and northwest"
;
caveRoom74: caveRoom
    north = caveRoom75
    sw = caveRoom73
    dirdesc = "north and southwest"
;
caveRoom101: caveRoom
    north = caveRoom114
    south = caveRoom100
    nw = caveRoom112
    se = caveRoom73
    dirdesc = "north, south, northwest, and southeast"
;
caveRoom75: caveRoom
    north = caveRoom122
    south = caveRoom74
    nw = caveRoom128
    se = caveRoom76
    dirdesc = "north, south, northwest, and southeast"
;
caveRoom120: caveRoom
    south = caveRoom121
    nw = caveRoom118
    dirdesc = "south and northwest"
;
caveRoom100: caveRoom
    north = caveRoom101
    west = caveRoom99
    se = caveRoom80
    dirdesc = "north, west, and southeast"
;
caveRoom114: caveRoom
    south = caveRoom101
    nw = caveRoom111
    up = caveRoom115
    dirdesc = "south, northwest, and up"
;
caveRoom112: caveRoom
    north = caveRoom111
    se = caveRoom101
    up = caveRoom113
    dirdesc = "north, southeast, and up"
;
caveRoom122: caveRoom
    south = caveRoom75
    nw = caveRoom123
    dirdesc = "south and northwest"
;
caveRoom128: caveRoom
    nw = caveRoom117
    se = caveRoom75
    dirdesc = "northwest and southeast"
;
caveRoom118: caveRoom
    north = caveRoom117
    se = caveRoom120
    up = caveRoom119
    dirdesc = "north, southeast, and up"
;
caveRoom92: caveRoom
    west = caveRoom93
    se = caveRoom81
    dirdesc = "west and southeast"
;
caveRoom99: caveRoom
    north = caveRoom102
    east = caveRoom100
    nw = caveRoom97
    dirdesc = "north, east, and northwest"
;
caveRoom111: caveRoom
    north = caveRoom110
    south = caveRoom112
    se = caveRoom114
    dirdesc = "north, south, and southeast"
;
caveRoom115: caveRoom
    down = caveRoom114
    iscaveledge = true
    dirdesc = "down"
;
caveRoom113: caveRoom
    down = caveRoom112
    iscaveledge = true
    dirdesc = "down"
;
caveRoom117: caveRoom
    north = caveRoom127
    south = caveRoom118
    nw = caveRoom116
    se = caveRoom128
    dirdesc = "north, south, northwest, and southeast"
;
caveRoom119: caveRoom
    down = caveRoom118
    iscaveledge = true
    dirdesc = "down"
;
caveRoom93: caveRoom
    east = caveRoom92
    nw = caveRoom94
    dirdesc = "east and northwest"
;
caveRoom102: caveRoom
    south = caveRoom99
    nw = caveRoom103
    dirdesc = "south and northwest"
;
caveRoom97: caveRoom
    nw = caveRoom96
    se = caveRoom99
    up = caveRoom98
    dirdesc = "northwest, southeast, and up"
;
caveRoom123: caveRoom
    north = caveRoom124
    se = caveRoom122
    dirdesc = "north and southeast"
;
caveRoom110: caveRoom
    north = caveRoom116
    south = caveRoom111
    nw = caveRoom109
    dirdesc = "north, south, and northwest"
;
caveRoom127: caveRoom
    north = caveRoom126
    south = caveRoom117
    dirdesc = "north and south"
;
caveRoom116: caveRoom
    south = caveRoom110
    nw = caveRoom129
    se = caveRoom117
    dirdesc = "south, northwest, and southeast"
;
caveRoom94: caveRoom
    nw = caveRoom95
    se = caveRoom93
    dirdesc = "northwest and southeast"
;
caveRoom103: caveRoom
    north = caveRoom108
    nw = caveRoom104
    se = caveRoom102
    dirdesc = "north, northwest, and southeast"
;
caveRoom96: caveRoom
    north = caveRoom104
    south = caveRoom95
    se = caveRoom97
    dirdesc = "north, south, and southeast"
;
caveRoom98: caveRoom
    down = caveRoom97
    iscaveledge = true
    dirdesc = "down"
;
caveRoom124: caveRoom
    south = caveRoom123
    nw = caveRoom126
    up = caveRoom125
    dirdesc = "south, northwest, and up"
;
caveRoom109: caveRoom
    north = caveRoom129
    south = caveRoom107
    se = caveRoom110
    dirdesc = "north, south, and southeast"
;
caveRoom126: caveRoom
    south = caveRoom127
    west = caveRoom131
    se = caveRoom124
    dirdesc = "south, west, and southeast"
;
caveRoom125: caveRoom
    down = caveRoom124
    iscaveledge = true
    dirdesc = "down"
;
caveRoom129: caveRoom
    north = caveRoom130
    south = caveRoom109
    nw = caveRoom133
    se = caveRoom116
    dirdesc = "north, south, northwest, and southeast"
;
caveRoom131: caveRoom
    east = caveRoom126
    nw = caveRoom130
    dirdesc = "east and northwest"
;
caveRoom130: caveRoom
    south = caveRoom129
    nw = caveRoom132
    se = caveRoom131
    dirdesc = "south, northwest, and southeast"
;
caveRoom133: caveRoom
    north = caveRoom132
    south = caveRoom134
    se = caveRoom129
    dirdesc = "north, south, and southeast"
;
caveRoom95: caveRoom
    north = caveRoom96
    se = caveRoom94
    dirdesc = "north and southeast"
;
caveRoom108: caveRoom
    north = caveRoom107
    south = caveRoom103
    dirdesc = "north and south"
;
caveRoom104: caveRoom
    north = caveRoom105
    south = caveRoom96
    se = caveRoom103
    dirdesc = "north, south, and southeast"
;
caveRoom105: caveRoom
    north = caveRoom106
    south = caveRoom104
    dirdesc = "north and south"
;
caveRoom106: caveRoom
    north = caveRoom134
    south = caveRoom105
    nw = caveRoom135
    se = caveRoom107
    dirdesc = "north, south, northwest, and southeast"
;
caveRoom134: caveRoom
    north = caveRoom133
    south = caveRoom106
    nw = caveRoom138
    dirdesc = "north, south, and northwest"
;
caveRoom135: caveRoom
    nw = caveRoom137
    se = caveRoom106
    up = caveRoom136
    dirdesc = "northwest, southeast, and up"
;
caveRoom107: caveRoom
    north = caveRoom109
    south = caveRoom108
    nw = caveRoom106
    dirdesc = "north, south, and northwest"
;
caveRoom138: caveRoom
    west = caveRoom137
    se = caveRoom134
    dirdesc = "west and southeast"
;
caveRoom137: caveRoom
    east = caveRoom138
    west = caveRoom140
    ne = caveRoom139
    se = caveRoom135
    dirdesc = "east, west, northeast, and southeast"
;
caveRoom136: caveRoom
    down = caveRoom135
    iscaveledge = true
    dirdesc = "down"
;
caveRoom132: caveRoom
    south = caveRoom133
    west = caveRoom139
    se = caveRoom130
    dirdesc = "south, west, and southeast"
;
caveRoom140: caveRoom
    east = caveRoom137
    west = caveRoom141
    nw = caveRoom142
    dirdesc = "east, west, and northwest"
;
caveRoom139: caveRoom
    east = caveRoom132
    sw = caveRoom137
    dirdesc = "east and southwest"
;
caveRoom141: caveRoom
    east = caveRoom140
    dirdesc = "east"
;
dreamAccel: fixeditem
    sdesc = "accelerator"
    noun = 'accelerator'
    adjective = 'particle'
    ldesc = "It looks like most other big particle accelerators, except
     that, being in a high school physics lab, it's sort of cheap and
     wimpy. A large warning label reads \"RADIATION! Type: M-rays;
     Nature: highly unstable.\" "
    location = dreamLab2
;
dreamLab2: room
    sdesc = "Accelerator Room"
    ldesc = "You are in the accelerator room, which is an annex to your high
     school's physics lab. A huge particle accelerator dominates the room. It's
     labelled \"RADIATION! Type: M-rays; Nature: highly unstable.\" A
     passage leads west. "
    west = dreamLab
    enterRoom( actor ) =
    {
        if ( actor.isCarrying( zeeniteD ))
        {
            "\bYou notice the xenite becoming hot. It becomes really
            hot. Really, seriously, extremely hot. After a few
            more adjectives which we won't go into here, you realize
            that this room contains an accelerator, which emits M-rays
            of a highly unstable nature. \"Xenite and M-rays of
            a highly unstable nature don't mix,\" the old saying goes.
            You finally think to drop the xenite and get far, far away
            from it, but it's too late. The xenite explodes in a terrible
            blast. ";
            xeniteDream.endDream;
        }
        pass enterRoom;
    }
;
zeeniteD: item
    sdesc = "small chunk of xenite"
    noun = 'xenite' 'chunk'
    adjective = 'small'
    location = dreamLab
;
dreamSwamp1: swampRoom
    myplant = dreamPlant1
    north = dreamSwamp2
    dirdesc = "north"
;
dreamPlant1: swampPlant
    location = dreamSwamp1
    myredspot = dreamRedSpot1
;
dreamSwamp2: swampRoom
    myplant = dreamPlant2
    north = dreamSwamp3
    dirdesc = "north"
    enterRoom( actor ) =
    {
        "You wade northwards into the swamp. You shortly
        come across another plant.
        \n\tSuddenly, from the muck, a huge and terrifying ";
        monster1.sdesc; " emerges. The beast starts coming your way;
        you try to run, but cannot!  Just as you're sure
        there's no escape, the beast halts and looks up.
        After a moment, you hear a whistling sound,
        like something falling from high above. You look
        up to see the strange balloon creature falling from
        the south.
        \n\tThe beast looks more terrified than you, and
        runs away whimpering to the north. You try to run
        for cover yourself, but before you can move, the
        balloon lands in the open jaws of the plant.
        \n\tOnce again, you feel compelled to touch the
        plant's red spot, and once again, the plant ejects
        the balloon to the east.\b";
        pass enterRoom;
    }
;
dreamPlant2: swampPlant
    location = dreamSwamp2
    myredspot = dreamRedSpot2
;
dreamSwamp3: room
    sdesc = "Swamp"
    ldesc = "You're in a foul swamp. "
    enterRoom( actor ) =
    {
        "\bThere's "; monster1.adesc; " here! You reel in terror,
        but before you've had a chance to do anything, another beast enters
        from the south.  The two "; monsterItem.sdesc; "s suddenly see
        each other, and look
        even more startled and terrified than you do (which is quite a trick).
        With remarkable agility, the first beast leaps straight
        into the air.  It lands in the gaping jaws of the plant.
        The second turns around as fast as it can and heads back the
        way it came.
        \b\tYou feel compelled to approach the plant, even with the
        fierce beast in its jaws. You timidly reach out and touch the
        spot. As you do, the plant starts to convulse wildly; after a
        few moments, it spits "; monsterItem.thedesc; " high into the air to
        the west. ";
        swampDream.endDream;
    }
;
dreamRedSpot2: redPlantSpot
    location = dreamSwamp2
    dirname = "north"
    nextroom = dreamSwamp3
    monstroom = dreamSwamp3
;
dreamRedSpot1: redPlantSpot
    location = dreamSwamp1
    dirname = "north"
    nextroom = dreamSwamp2
    monstroom = dreamSwamp2
;
class reactorLight: fixeditem
    sdesc = "indicator light"
    noun = ['light']
    adjective = ['indicator']
    plural = ['lights']
    location = reactorControl
    color =
    {
        if ( self.status = 1 ) "green";
        else if ( self.status = 2 ) "yellow";
        else "red";
    }
    ldesc = "The light is << self.color >>. "
    status = 3
    increment =
    {
        self.status := self.status + 1;
        if ( self.status = 4 ) self.status := 1;
    }
    decrement =
    {
        self.status := self.status - 1;
        if ( self.status = 0 ) self.status := 3;
    }
;
reactorLight2: reactorLight
    sdesc = "pressure indicator light"
    adjective = 'pressure'
;
reactorLight3: reactorLight
    sdesc = "radiation indicator light"
    adjective = 'radiation' 'rad'
;
reactorLight4: reactorLight
    sdesc = "atmosphere indicator light"
    adjective = 'atmosphere'
;
reactorLight1: reactorLight
    sdesc = "temperature indicator light"
    adjective = 'temperature' 'temp'
;
reactorBoard: fixeditem
    sdesc = "big board"
    noun = 'board'
    adjective = 'big'
    location = reactorControl
    ldesc =
    {
        "The Big Board indicates the current status of
        the reactor. "; self.lightdesc;
    }
    lightdesc =
    {
        "The current indicator lights:
        \n\tTemperature:\t<< reactorLight1.color >>
        \n\tPressure:\t\t<< reactorLight2.color >>
        \n\tRadiation:\t\t<< reactorLight3.color >>
        \n\tAtmosphere:\t\t<< reactorLight4.color >> ";

        if ( reactorLight1.status = 1 and
         reactorLight2.status = 1 and
         reactorLight3.status = 1 and
         reactorLight4.status = 1 )
        {
            if ( not reactorDoor.isopen )
            {
                "\bThe emergency containment door opens. ";
                reactorDoor.isopen := true;
                if ( not reactorDoor.hasScored )
                {
                    incscore( 10 );
                    reactorDoor.hasScored := true;
                }
            }
        }
        else
        {
            if ( reactorDoor.isopen )
            {
                "\bThe emergency containment door closes. ";
                reactorDoor.isopen := nil;
            }
        }
    }
;
class reactorButton: buttonitem
    location = reactorControl
;
reactorButton1: reactorButton
    adjective = '1'
    doPush( actor ) =
    {
        local tmp;
        tmp := reactorLight1.status;
        reactorLight1.status := reactorLight4.status;
        reactorLight4.status := reactorLight2.status;
        reactorLight2.status := reactorLight3.status;
        reactorLight3.status := tmp;

        reactorBoard.lightdesc;
    }
;
reactorButton2: reactorButton
    adjective = '2'
    doPush( actor ) =
    {
        reactorLight1.decrement;
        reactorLight2.increment;
        reactorBoard.lightdesc;
    }
;
reactorButton3: reactorButton
    adjective = '3'
    doPush( actor ) =
    {
        reactorLight2.increment;
        reactorLight3.decrement;
        reactorBoard.lightdesc;
    }
;
reactorButton4: reactorButton
    adjective = '4'
    doPush( actor ) =
    {
        reactorLight1.decrement;
        reactorLight3.decrement;
        reactorBoard.lightdesc;
    }
;
reactorDoor: fixeditem
    sdesc = "emergency door"
    location = reactorControl
    noun = 'door'
    adjective = 'emergency' 'containment'
    ldesc = "The emergency door is automatically
        sealed when the reactor is unsafe.
        It is currently << self.isopen ? "open" : "closed" >>. "
    isopen = nil
    verDoOpen( actor ) =
    {
        "The door is operated automatically by the reactor
        control equipment. ";
    }
    verDoClose( actor ) = { self.verDoOpen( actor ); }
;

]]--
