using IFUniPlayer.UWP;
using Xamarin.Forms;

[assembly: Dependency(typeof(BaseUrl))]
namespace IFUniPlayer.UWP
{
    public class BaseUrl : IBaseUrl
    {
        public string Get()
        {
            return "ms-appx-web:///";
        }
    }
}
