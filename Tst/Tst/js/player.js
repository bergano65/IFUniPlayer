"use strict";

//require("lua.vm.js");

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
    debugger;
    var code = " require('..\\games\\" + game + "\\game.lua') " +
        "local g = startGame() " +
        " setScore(g.name, g.turns, g.points, g.maxpoints) ";
    console.log("playgame-" + code);
    code = " print('~2~')";
    Lua.exec(code);

    console.log("playgame-end");
}

