using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IFUniPlayer;
using IFUniPlayer.UWP;
using Xamarin.Forms.Platform.UWP;
using Windows.UI.Xaml.Controls;
using Windows.Storage;
using Windows.Storage.Search;
using System.Reflection;
using System.IO;
using Windows.Storage.Pickers;
using PCLStorage;

[assembly:ExportRenderer(typeof(HybridWebView), typeof(HybridWebViewRenderer))]
namespace IFUniPlayer.UWP
{
    public class HybridWebViewRenderer : ViewRenderer<HybridWebView, Windows.UI.Xaml.Controls.WebView>
       {
        private IFolder playerFolder;

        public HybridWebViewRenderer()
        {
            CreatePlayerSet();
        }

        private void CreatePlayerSet()
        {
            IFolder folder = PCLStorage.FileSystem.Current.LocalStorage;
            Task<IFolder> playerFolderTask = folder.GetFolderAsync("IFUniPlayer");
            playerFolder = null;
            try
            {
                playerFolderTask.Wait();
                playerFolder = playerFolderTask.Result;
            }
            catch (Exception e)
            {
            }

            if (playerFolder != null)
            {
                playerFolder.DeleteAsync().Wait();
            }

            playerFolderTask = folder.CreateFolderAsync("IFUniPlayer", PCLStorage.CreationCollisionOption.ReplaceExisting);
            playerFolderTask.Wait();
            playerFolder = playerFolderTask.Result;

            File.Copy("Player.html", Path.Combine(playerFolder.Path, "Player.html"));
            File.Copy("lamp.png", Path.Combine(playerFolder.Path, "lamp.png"));

            Task<IFolder> jsFolderTask = playerFolder.CreateFolderAsync("js", PCLStorage.CreationCollisionOption.ReplaceExisting);
            jsFolderTask.Wait();

            StorageFolder storageFolder = Windows.ApplicationModel.Package.Current.InstalledLocation;
            foreach (string f in Directory.GetFiles(Path.Combine(storageFolder.Path, "js")))
            {
                string fname = Path.GetFileName(f);
                File.Copy(f, Path.Combine(playerFolder.Path, "js", fname));
            }
        }

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

                try
                {
                    // {ms-appx-web:///C:/Users/Administrator/AppData/Local/Packages/39ad6d05-8576-4b07-95d0-b39c5a24c3b0_emh4s6j6ymhkg/LocalState/IFUniPlayer/Player.html}
                    Uri addr = new Uri(string.Format("ms-appx-web:///{0}", Element.Uri));
                    Control.Source = addr;
                }
                catch(Exception ee)
                {

                }
            }
        }

        private void Control_NavigationStarting(WebView sender, WebViewNavigationStartingEventArgs args)
        {
        }

        async void OnWebViewNavigationCompleted(WebView sender, WebViewNavigationCompletedEventArgs args)
        { 
//            File.WriteAllText("Cmd.html", "");
        }
        
        async void OnWebViewScriptNotify(object sender, NotifyEventArgs e)
        {
            string response = Player.Instance.Execute(e.Value);

            File.WriteAllText(Path.Combine(playerFolder.Path, "Cmd.html"), response);
          }

        private StorageFile ChooseTempFolder()
        {
            FileSavePicker savePicker = new FileSavePicker();
            savePicker.SuggestedStartLocation = PickerLocationId.PicturesLibrary;
            // Dropdown of file types the user can save the file as
            savePicker.FileTypeChoices.Add("Html", new List<string>() { ".html" });
            // Default file name if the user does not type one in or select a file to replace
            savePicker.SuggestedFileName = "Cmd.html";

            Task<StorageFile> t = savePicker.PickSaveFileAsync().AsTask<StorageFile>();
            t.Wait();
            return t.Result;
        }
    }
}
