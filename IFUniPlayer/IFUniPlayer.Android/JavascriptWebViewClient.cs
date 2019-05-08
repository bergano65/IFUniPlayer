using Android.App;
using Android.Graphics;
using Android.Webkit;
using IFUniPlayer;
using System.IO;
using PCLStorage;
using System.Threading.Tasks;

namespace IFUniPlayer.Android
{
    public class JavascriptWebViewClient : WebViewClient
    {
        string _javascript;

        public JavascriptWebViewClient(string javascript)
        {
            _javascript = javascript;
        }

        public override void OnPageStarted(WebView view, string url, Bitmap favicon)
        {
            base.OnPageStarted(view, url, favicon);
        }

        public override WebResourceResponse ShouldInterceptRequest(WebView view, string url)
        {
            WebResourceResponse response = base.ShouldInterceptRequest(view, url);
            return response;
        }

        public override bool ShouldOverrideUrlLoading(WebView view, string url)
        {
            if (url.Contains("Command"))
            {
                // command received let's execute
                string cmd = url.Substring(url.IndexOf("Command") + 8);
                string response = Player.Instance.Execute(cmd);


                IFolder folder = PCLStorage.FileSystem.Current.LocalStorage;
                Task<IFile> task = folder.CreateFileAsync("Cmd.html", CreationCollisionOption.ReplaceExisting);
                task.Wait();
                IFile file = task.Result;
                file.WriteAllTextAsync(response).Wait();

                return true;
            }

            return base.ShouldOverrideUrlLoading(view, url);
        }


        public override void OnPageFinished(WebView view, string url)
        {
            base.OnPageFinished(view, url);
            view.EvaluateJavascript(_javascript, null);
        }
    }
}
