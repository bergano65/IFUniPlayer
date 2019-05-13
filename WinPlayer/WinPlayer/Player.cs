using MoonSharp.Interpreter;
using System;
using System.IO;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;

namespace IFUniPlayer
{
    public class Player
    {
        private static Player player;

        public string Description { get; set; }

        public string Name { get; set; }

        public double Turns { get; set; }

        public double Points { get; set; }

        public double Maxpoints { get; set; }


        public Table CurrentGame { get; set; }

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

        public string Execute(string cmd)
        {
            if (cmd.StartsWith("play/"))
            {
                return RunGame(cmd);
            }

            return null;
        }


        public int ShowStart(Table table)
        {
            string description = (string)table["description"];

            Description = description;

            UpdateScore(table);

            return 0;
        }


        public int UpdateScore(Table table)
        {
            string name = (string)table["name"];
            double turns = (double)table["turns"];
            double points = (double)table["points"];
            double maxPoints = (double)table["maxpoints"];

            Name = name;
            Turns = turns;
            Points = points;
            Maxpoints = maxPoints;

            return 0;
        }

        public string RunGame(string game)
        {
                        ScriptLoader scriptLoader = new ScriptLoader("sample");
            scriptLoader = new ScriptLoader("");
            Script.DefaultOptions.ScriptLoader = scriptLoader;
            Script.DefaultOptions.DebugPrint = s =>
            {};

            Script script = new Script();
            script.Globals["hostUpdateScore"] = (Func<Table, int>)UpdateScore;
            script.Globals["hostShowStart"] = (Func<Table, int>)ShowStart;
            
            // run script
            try
            {
                Table globalCtxt = new Table(script);
                CurrentGame = script.DoString("require \"game\" \r\n return startGame()").Table;
                ShowStart(CurrentGame);
                return GetState();
            }
            catch (Exception e)
            {
                return null;
            }
        }

        public string GetState()
        {
            StringBuilder stringBuilder = new StringBuilder();
            StringWriter stringWriter = new StringWriter(stringBuilder);

            using (JsonWriter writer = new JsonTextWriter(stringWriter))
            {
                writer.Formatting = Formatting.Indented;

                writer.WriteStartObject();
                writer.WritePropertyName("name");
                writer.WriteValue(CurrentGame["name"]);
                writer.WritePropertyName("description");
                writer.WriteValue(CurrentGame["description"]);
                writer.WritePropertyName("turns");
                writer.WriteValue(CurrentGame["turns"]);
                writer.WritePropertyName("points");
                writer.WriteValue(CurrentGame["points"]);
                writer.WritePropertyName("maxpoints");
                writer.WriteValue(CurrentGame["maxpoints"]);
                writer.WriteEndObject();
                return stringWriter.ToString();
            }
        }

    }
}
