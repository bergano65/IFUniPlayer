using MoonSharp.Interpreter;
using System;
using Xamarin.Forms;

namespace IFUniPlayer
{
    public class Player
    {
        private static Player player;

        public Game Game { get; set; }

        public Page MainView { get; set; }

        public Editor Editor  { get; set; }

        public Label ScoreLabel { get; set; }

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

        public int SetGame(Table table)
        {
            Editor.Text = (string)table["description"];
            UpdateScore(table);
            return 0;
       }

        public int UpdateScore(Table table)
        {
            string name = (string)table["name"];
            double turns = (double)table["turns"];
            double points = (double)table["points"];
            double maxPoints = (double)table["maxpoints"];

            string status;        
            if (maxPoints != 0)
            {
                status = string.Format("{0}\r\n{1} turns {2}/{3} points", name, turns, points, maxPoints);
            }
            else
            {
                status = string.Format("{0}\r\n{1} turns {2}/{3} points", name, turns, points, maxPoints);
            }

            ScoreLabel.Text = status;

            
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
            script.Globals["hostSetGame"] = (Func<Table, int>)SetGame;
            script.Globals["hostUpdateScore"] = (Func<Table, int>)UpdateScore;
            Game = new Game();

            // run script
            try
            {
                Table globalCtxt = new Table(script);
//                DynValue res = script.DoString("require \"test\" \r\nmain() \r\n");
                Table  currentGame = script.DoString("require \"game\" \r\nstartGame() \r\n return currentGame").Table;
            }
            catch (Exception e)
            {
                Player.Instance.Editor.Text += e.Message;
            }

            ShowMainView();

        }

    }
}
