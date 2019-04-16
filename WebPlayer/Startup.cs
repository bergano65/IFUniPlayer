using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(WebPlayer.Startup))]
namespace WebPlayer
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
