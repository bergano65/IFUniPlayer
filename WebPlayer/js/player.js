"use strict";

require("lua.vm.js");

function restart()
{
    alert('+');
}

function open()
{
        window.external.notify("open");
}

function save()
{
        window.external.notify("save");
}

function help()
{
        window.external.notify("help");
}

function about()
{
        window.external.notify("about");
}

function play(game)
{
    console.log("playgame-" + game);
    var code = " require('..\\games\\" + game + "\\game.lua') " +
        "local g = startGame() " +
        " setScore(g.name, g.turns, g.points, g.maxpoints) ";
    console.log("playgame-" + code);
    debugger;
    code = " setScore('dsd', 2, 3, 0) print(\"d~d\") ";
    Lua.exec(code);
    console.log("playgame-end");
}

