using System;
using System.Collections.Generic;
using System.Text;
using MoonSharp;
using MoonSharp.VsCodeDebugger;
using MoonSharp.Interpreter.Debugging;
using MoonSharp.Interpreter;
using MoonSharp.Interpreter.Loaders;

using Xamarin;
using Xamarin.Forms;

namespace IFUniPlayer
{
    public class Player
    {
        private static Player player;

        public Page MainView { get; set; }

        public static Player Instance
        {
            get
            {
                if (player == null)
                {
                    player = new Player();
                }

                return player;
            }
        }

        public void ShowMainView()
        {
            Application.Current.MainPage = new NavigationPage(MainView);
        }

        public void RunGame(string game)
        {
            ScriptLoader scriptLoader = new ScriptLoader("sample");
            scriptLoader = new ScriptLoader("");
            Script.DefaultOptions.ScriptLoader = scriptLoader;
            Script.DefaultOptions.DebugPrint = s => Console.WriteLine(s.ToLower());
            Script script = new Script();

/*
 MoonSharpVsCodeDebugServer server = new MoonSharpVsCodeDebugServer();
            server.Start();
            server.AttachToScript(script, "DebugScript");
*/
            // run script
            Table globalCtxt = new Table(script);
//            DynValue res = script.DoString("print('~')\r\n return 5");
            DynValue res = script.DoString("require \"test\" \r\nmain() \r\n");

            ShowMainView();

        }
    }
}
