using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Reflection;

using MoonSharp;
using MoonSharp.Interpreter;
using MoonSharp.Interpreter.Loaders;

namespace IFUniPlayer
{
    public class ScriptLoader : ScriptLoaderBase
    {
        private string gameName;

        public ScriptLoader(string gameName)
        {
            
        }

        public override object LoadFile(string file, Table globalContext)
        {
            string assemblyName = Assembly.GetExecutingAssembly().CodeBase;
            string fileName = assemblyName.Replace("file://", "");
            fileName = Path.Combine(fileName, "sample/" + file + ".lua");

            return null;
        }

        public override bool ScriptFileExists(string name)
        {
            return true;
        }

        public override string ResolveModuleName(string modname, Table globalContext)
        {
            return modname;
//            return base.ResolveModuleName(modname, globalContext);
        }

        public override string ResolveFileName(string filename, Table globalContext)
        {
            return filename;
//            return base.ResolveFileName(filename, globalContext);
        }
    }
}
