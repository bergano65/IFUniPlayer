using System;
using Xamarin.Forms;
using IFUniPlayer.Android;
using IFUniPlayer;

[assembly: Dependency (typeof (BaseUrl_Android))]
namespace IFUniPlayer.Android 
{
	public class BaseUrl_Android : IBaseUrl 
	{
		public string Get () 
		{
			return "file:///android_asset/";
		}
	}
}