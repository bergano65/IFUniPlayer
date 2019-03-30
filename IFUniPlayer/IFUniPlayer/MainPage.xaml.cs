using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;

namespace IFUniPlayer
{ 
    public partial class MainPage : ContentPage
    {
        public MainPage()
        {
            InitializeComponent();
            Player.Instance.MainView = this;
            Player.Instance.Editor = _gameEditor;
        }

        private void MenuButtonClicked(object sender, EventArgs e)
        {
           Application.Current.MainPage = new NavigationPage(new MenuPage());
        }
    }
}
