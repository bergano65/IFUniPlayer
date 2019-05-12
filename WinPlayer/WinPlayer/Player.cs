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
        public int UpdateScore(Table table)
        {
            string name = (string)table["name"];
            double turns = (double)table["turns"];
            double points = (double)table["points"];
            double maxPoints = (double)table["maxpoints"];
            
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
            
            // run script
            try
            {
                Table globalCtxt = new Table(script);
                CurrentGame = script.DoString("require \"game\" \r\n return startGame()").Table;

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
            catch (Exception e)
            {
                return null;
            }
        }

    }
}
