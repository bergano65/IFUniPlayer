using System;

using Xamarin.Forms;

namespace IFUniPlayer
{
	public class HybridWebViewPage : ContentPage
	{
		public HybridWebViewPage ()
		{
			var hybridWebView = new HybridWebView {
				Uri = "Player.html",
				HorizontalOptions = LayoutOptions.FillAndExpand,
				VerticalOptions = LayoutOptions.FillAndExpand
			};

			hybridWebView.RegisterAction (data => DisplayAlert ("Alert", "Hello " + data, "OK"));

			Padding = new Thickness (0, 20, 0, 0);
			Content = hybridWebView;
		}
	}
}
