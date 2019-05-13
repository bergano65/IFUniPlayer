using System;   
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Path = System.IO.Path;
using CefSharp.Wpf;
using CefSharp;
using MoonSharp.Interpreter;
using IFUniPlayer;

namespace WinPlayer
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        InteropObject _interOp;

        public MainWindow()
        {
            var settings = new CefSettings();
            settings.BrowserSubprocessPath = @"x86\CefSharp.BrowserSubprocess.exe";

            CefSharpSettings.LegacyJavascriptBindingEnabled = true;
            Cef.Initialize(settings, performDependencyCheck: false, browserProcessHandler: null);

            InitializeComponent();
            Assembly assembly = Assembly.GetEntryAssembly();
            string codeBase = assembly.CodeBase;
            Uri codeBaseUri = new Uri(codeBase);
            try
            {
                _webView.ConsoleMessage += _webView_ConsoleMessage;
                string appDir = Path.GetDirectoryName(codeBaseUri.AbsolutePath);
                _webView.Address = Path.Combine(appDir, "Content/Player.html");
                _interOp = new InteropObject();
                _webView.IsBrowserInitializedChanged += _webView_IsBrowserInitializedChanged;
                _webView.RegisterJsObject("interOp", _interOp);
                _webView.RegisterJsObject("player", Player.Instance);
            }
            catch (Exception e)
            {
            }
        }

        private void _webView_IsBrowserInitializedChanged(object sender, DependencyPropertyChangedEventArgs e)
        {
            WebBrowserExtensions.ShowDevTools(_webView);
        }

        private void _webView_ConsoleMessage(object sender, ConsoleMessageEventArgs e)
        {
        }
    }
}
