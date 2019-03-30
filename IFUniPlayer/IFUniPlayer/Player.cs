using System;
using System.Collections.Generic;
using System.Diagnostics;
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

        public Editor Editor  { get; set; }

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

        public static int SetGame(DynValue game)
        {
            return 0;
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
            Script.DefaultOptions.DebugPrint = s =>
            Editor.Text += "\r\n" + s.ToLower() ;

            Script script = new Script();
            script.Globals["setGame"] = (Func<DynValue, int>)SetGame;

            /*
             MoonSharpVsCodeDebugServer server = new MoonSharpVsCodeDebugServer();
                        server.Start();
                        server.AttachToScript(script, "DebugScript");
            */
            // run script
            try
            {
                Table globalCtxt = new Table(script);
                //            DynValue res = script.DoString("print(10'~')\r\n return 5");
                DynValue res = script.DoString("require \"game\" \r\nstartGame() \r\n");

            }
            catch (Exception e)
            {
                Player.Instance.Editor.Text += e.Message;
            }

            ShowMainView();

        }
    }
}
