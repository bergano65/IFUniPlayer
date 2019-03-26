using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using MoonSharp;
using MoonSharp.Interpreter;
using MoonSharp.Interpreter.Loaders;

using IFUniPlayer;

namespace CUnitTests
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod1()
        {
            FileSystemScriptLoader fileSystemScriptLoader = new FileSystemScriptLoader();
            bool i = fileSystemScriptLoader.ScriptFileExists("1/MoonSharp.Interpreter.xml");
            Script script = new Script();
            script.Options.ScriptLoader = new ScriptLoader("");

            script.DoString("require \"game\"");
        }
    }
}
