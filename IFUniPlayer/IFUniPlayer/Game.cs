using System;
using System.Collections.Generic;
using System.Text;

using MoonSharp.Interpreter;

namespace IFUniPlayer
{
    [MoonSharpUserData]
    public class Game
    {
        public string Name { get; set; }

        public string Description { get; set; }

        public int MaxPoints { get; set; }

        public int Points { get; set; }

        public event EventHandler Changed;

        public void SignalChanged()
        {
            if (Changed != null)
            {
                Changed(this, EventArgs.Empty);
            }
        }
    }
}
