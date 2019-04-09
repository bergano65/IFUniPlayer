using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(WebUIPlayer.Startup))]
namespace WebUIPlayer
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
