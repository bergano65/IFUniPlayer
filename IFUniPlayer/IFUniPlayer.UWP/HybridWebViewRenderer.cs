using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IFUniPlayer;
using IFUniPlayer.UWP;
using Xamarin.Forms.Platform.UWP;
using Windows.UI.Xaml.Controls;

[assembly:ExportRenderer(typeof(HybridWebView), typeof(HybridWebViewRenderer))]
namespace IFUniPlayer.UWP
{
    public class HybridWebViewRenderer : ViewRenderer<HybridWebView, Windows.UI.Xaml.Controls.WebView>
    {

        protected override void OnElementChanged(ElementChangedEventArgs<HybridWebView> e)
        {
            base.OnElementChanged(e);

            if (Control == null)
            {
                WebView view = new Windows.UI.Xaml.Controls.WebView();
                view.Settings.IsJavaScriptEnabled = true;
                SetNativeControl(view);
            }
            if (e.OldElement != null)
            {
                Control.NavigationStarting -= Control_NavigationStarting;
                Control.NavigationCompleted -= OnWebViewNavigationCompleted;
                Control.ScriptNotify -= OnWebViewScriptNotify;
            }
            if (e.NewElement != null)
            {
                Control.NavigationStarting += Control_NavigationStarting;
                Control.NavigationCompleted += OnWebViewNavigationCompleted;
                Control.ScriptNotify += OnWebViewScriptNotify;
                Control.Source = new Uri(string.Format("ms-appx-web:///{0}", Element.Uri));
            }
        }

        private void Control_NavigationStarting(WebView sender, WebViewNavigationStartingEventArgs args)
        {
        }

        async void OnWebViewNavigationCompleted(WebView sender, WebViewNavigationCompletedEventArgs args)
        {
            if (args.IsSuccess)
            {
                // Inject JS script
                WebView view = Control as WebView;
                const string JavaScriptFunction = "function invokeCSharpAction(data){window.external.notify(data);}";

//                string[] a = new string[] { "alert('!');" };
                string[] a = new string[] { JavaScriptFunction };

//                await view.InvokeScriptAsync("ev", a);
                                await Control.InvokeScriptAsync("eval", new[] { "alert('++');" });
            }
        }

        async void OnWebViewScriptNotify(object sender, NotifyEventArgs e)
        {
            Element.InvokeAction(e.Value);
        }
    }
}
 