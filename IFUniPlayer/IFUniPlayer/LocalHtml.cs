using System.Linq;
using System.IO;
using System.Reflection;
using Xamarin.Forms;

namespace IFUniPlayer
{
    public class LocalHtml : ContentPage
    {
        public LocalHtml()
        {
            var browser = new WebView();

            var htmlSource = new HtmlWebViewSource();

            htmlSource.Html = @"<html><body>
<h1>Xamarin.Forms</h1>
<p>Welcome to WebView.</p>
</body>
</html>";
            htmlSource.Html = GetHtml();
            browser.Source = htmlSource;
            Content = browser;
        }

      public string GetHtml()
      {
            Assembly assembly = Assembly.GetExecutingAssembly();
            string[] resources = assembly.GetManifestResourceNames();
            string resourceName = resources.Where(r => r.Contains("Player.html")).FirstOrDefault();

            if (resourceName == null)
            {
                return null;
            }

            Stream stream = assembly.GetManifestResourceStream(resourceName);
            long resourceLen = stream.Length;
            byte[] buffer = new byte[resourceLen];
            stream.Read(buffer, 0, (int)resourceLen);
            return System.Text.Encoding.Default.GetString(buffer);
        }

    }
}
