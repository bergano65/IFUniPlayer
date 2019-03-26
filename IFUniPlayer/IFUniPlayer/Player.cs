using System;
using System.Collections.Generic;
using System.Text;
using MoonSharp;
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
            Script script = new Script();

            Table globalCtxt = new Table(script);
            DynValue res = script.DoString("require \"game\" \r\ncreateGame() \r\n");

            ShowMainView();

        }
    }
}
