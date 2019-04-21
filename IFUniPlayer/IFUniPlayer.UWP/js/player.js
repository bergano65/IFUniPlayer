"use strict";
/*
const lua = require('fn/lua.js');
const lauxlib = require('fn/lauxlib.js');
const lualib = require('fn/lualib.js');
const { to_luastring } = require("fn/fengaricore.js");
*/


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
/*
    let L = lauxlib.luaL_newstate();
    if (!L) throw Error("failed to create lua state");

    let luaCode = `
        local f = function (a, b)
            return a + b
        end

        local c = f(1, 2)

        return c
    `;

     lauxlib.luaL_loadstring(L, to_luastring(luaCode));
    lua.lua_call(L, 0, -1);
    var r = lua.lua_tointeger(L, -1);
*/
}

