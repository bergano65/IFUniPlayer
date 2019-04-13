using System;
using Xamarin.Forms;

namespace IFUniPlayer
{
    public class WebPage : ContentPage
    {
        public WebPage()
        {
            var browser = new WebView();
            browser.Source = "httP://xamarin.cOM";
            Content = browser;
        }
    }
}

