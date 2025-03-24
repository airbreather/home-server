using Yarp.ReverseProxy.Transforms;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
    .AddTransforms(ctx =>
    {
        // Archipelago doesn't set strict_slashes. This seems to be the only spot where it matters?
        if (ctx.Cluster?.ClusterId == "archipelago")
        {
            ctx.AddRequestTransform(ctx =>
            {
                if (ctx.Path == "/tutorial")
                {
                    ctx.Path = "/tutorial/";
                }

                return ValueTask.CompletedTask;
            });
        }
    });

WebApplication app = builder.Build();

app.MapReverseProxy();

app.Run();
