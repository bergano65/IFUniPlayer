using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IFUniPlayer;

namespace WinPlayer
{
    public class InteropObject
    {
        public string _cmd;

        public string _response;

        public string Cmd
        {
            get
            {
                return _cmd;
            }

            set
            {
                _cmd = value;
                _response = Player.Instance.Execute(value);
            }
        }

        public string Response
        {
            get
            {
                return _response;
            }

            set
            {
                _response = value;
            }
        }

        public string ExecuteCommand(string cmd)
        {
            return "~";
        }
    }
}
