using System;
using Xamarin.Forms;

namespace IFUniPlayer
{
    public class App : Application // superclass new in 1.3
    {
        public App()
        {
            var tabs = new TabbedPage();
            LocalHtml view = new LocalHtml { Title = "Player" };
            tabs.Children.Add(view);

            tabs.Children.Add(new HybridWebViewPage { Title = "Callback" });

            tabs.Children.Add (new WebPage { Title = "Web Page"});
                       MainPage = tabs;
        }
    }
}


