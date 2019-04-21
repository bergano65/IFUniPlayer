﻿"use strict";

require("lua.vm.js");

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
    Lua.exec("js.global.alert('+l+')", "");
}

