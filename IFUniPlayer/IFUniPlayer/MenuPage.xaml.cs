using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace IFUniPlayer
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class MenuPage : ContentPage
    {
        public ObservableCollection<string> Items { get; set; }

        public ObservableCollection<GameCommand> Commands { get; set; }

        public MenuPage()
        {
            InitializeComponent();

            Items = new ObservableCollection<string>
            {
                "Game",
                "New",
                "Choose",
                "Load",
                "Save"
            };

            Commands = new ObservableCollection<GameCommand>
            {
                new GameCommand("Game", "Game"),
                new GameCommand("New", "New"),
                new GameCommand("Choose", "Choose"),
                new GameCommand("Load", "Load"),
                new GameCommand("Save", "Save")
            };

            menuListView.ItemsSource = Items;
        }

        async void Handle_ItemTapped(object sender, ItemTappedEventArgs e)
        {
            if (e.Item == null)
                return;
            string item = e.Item as string;

            GameCommand cmd = Commands.Where(c => c.Hash == item.GetHashCode()).FirstOrDefault();

            if (cmd != null)
            {
                ProceedCmd(cmd);
            }
            //  await DisplayAlert("Item Tapped", "An item was tapped.", "OK");

                // Deselect Item
            ((ListView)sender).SelectedItem = null;
        }

        private void ProceedCmd(GameCommand cmd)
        {
            switch (cmd.Cmd)
            {
                case "Choose":
                    Player.Instance.RunGame("C:\\projects\\IFUniPlayer\\IFUniPlayer\\IFUniPlayer.Android\\bin\\Debug\\Lua\\sample");
                    break;        
            }
        }
    }
}

