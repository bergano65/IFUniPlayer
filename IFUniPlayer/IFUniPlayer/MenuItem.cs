using System;
using System.Collections.Generic;
using System.Text;

namespace IFUniPlayer
{
    public class GameCommand
    {
        public string Text { get; set; }
        public string Cmd { get; set; }

        public int Hash { get; set; }

        public GameCommand(string cmd, string text)
        {
            Cmd = cmd;
            Text = text;
            Hash = text.GetHashCode();
        }
    }
}
