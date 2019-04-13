using System;
using Xamarin.Forms;

namespace IFUniPlayer
{
    public class App : Application // superclass new in 1.3
    {
        public App()
        {
            LocalHtml view = new LocalHtml { Title = "Player" };
            MainPage = view;
            /*
             *          var tabs = new TabbedPage();
                        tabs.Children.Add (new LocalHtmlBaseUrl {Title = "BaseUrl" });
                        tabs.Children.Add (new WebPage { Title = "Web Page"});
            /*
                        tabs.Children.Add (new WebAppPage {Title ="External"});
                        MainPage = tabs;
            */
        }
    }
}

