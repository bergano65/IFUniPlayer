"use strict";

//import * as lua from "lua.vm.js";
class FSImpl
{

    unlink(file)
    {
    }

    llseek(stream, offset, whence)
    {
    }

    lstat()
    {
    }

}

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
//    var FS = require('fs');


    debugger;

/*
 *var content;
    fs.readFile('g/game.lua', function read(err, data) {
        if (err) {
            throw err;
        }
        content = data;
    });
    console.log(content);
  */

    console.log("playgame-" + game);
 /*   var code = " require('game.lua') " +
//    var code = " require('..\\games\\" + game + "\\game.lua') " +
        "local g = startGame() " +
        " setScore(g.name, g.turns, g.points, g.maxpoints) ";
    code += " print('~22~')";
    console.log("playgame code-" + code);
*/

    var code = " print('~22~')";
    Lua.exec(code);

    console.log("playgame-end");
}

   