using System;
using IFUniPlayer;
using Xamarin.Forms;
using Xamarin.Forms.Platform.Android;
using Android.App;
using Android.Content;
using Android.Webkit;
using PCLStorage;
using System.Threading.Tasks;
using System.IO;
using IFUniPlayer.Android;
using WebView = Android.Webkit.WebView;

[assembly: ExportRenderer(typeof(HybridWebView), typeof(HybridWebViewRenderer))]
namespace IFUniPlayer.Android
{
    public class HybridWebViewRenderer : ViewRenderer<HybridWebView, WebView>
    {
        const string JavascriptFunction = "function invokeCSharpAction(data){jsBridge.invokeAction(data);}";
        Context _context;
        JavascriptWebViewClient _client;

        public HybridWebViewRenderer(Context context) : base(context)
        {
            _context = context;
            PrepareTempFiles();
        }

        private void PrepareTempFiles()
        {

            try
            {
                var assets = Forms.Context.Assets;
                IFolder folder = PCLStorage.FileSystem.Current.LocalStorage;

                StreamReader reader = new StreamReader(assets.Open("Content/Player.html"));
                string player = reader.ReadToEnd();
                File.WriteAllText(Path.Combine(folder.Path, "Player.html"), player);

                Stream lamp = assets.Open("Content/lamp.png");
                FileStream   lampTo = File.Open(Path.Combine(folder.Path, "lamp.png"), FileMode.Create);
                byte[] buf = new byte[1];
                while (lamp.IsDataAvailable())
                {
                    int l = lamp.ReadByte();
                    lampTo.WriteByte((byte)l);
                }

                lampTo.Flush();
            }
            catch (Exception e)
            {
            }
        }

        protected override void OnElementChanged(ElementChangedEventArgs<HybridWebView> e)
        {
            base.OnElementChanged(e);

            if (Control == null)
            {
                var webView = new WebView(_context);
                webView.Settings.JavaScriptEnabled = true;
                webView.Settings.AllowFileAccessFromFileURLs = true;
                webView.Settings.AllowUniversalAccessFromFileURLs = true;
                webView.Settings.DomStorageEnabled = true;

                _client = new JavascriptWebViewClient($"javascript: {JavascriptFunction}");
                webView.SetWebViewClient(_client);

                SetNativeControl(webView);
            }
            if (e.OldElement != null)
            {
                Control.RemoveJavascriptInterface("jsBridge");
                var hybridWebView = e.OldElement as HybridWebView;
                hybridWebView.Cleanup();
            }
            if (e.NewElement != null)
            {
                Control.AddJavascriptInterface(new JSBridge(this), "jsBridge");
                IFolder folder = PCLStorage.FileSystem.Current.LocalStorage;
//                Control.LoadUrl($"file:///android_asset/Content/{Element.Uri}");
                Control.LoadUrl(string.Format("file:///{0}/{1}", folder.Path, Element.Uri));
            }
        }
    }
}
