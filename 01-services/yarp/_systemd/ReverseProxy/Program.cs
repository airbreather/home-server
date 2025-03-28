using Microsoft.AspNetCore.HttpLogging;
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

builder.Services
    .AddW3CLogging(logging =>
    {
        logging.LoggingFields = W3CLoggingFields.All;
        logging.LogDirectory = "/app/yarp-logs";
    });

WebApplication app = builder.Build();

app.UseW3CLogging();

app.MapGet("/robots.txt", () => """
    User-agent: *
    Disallow: /
    """);
app.MapReverseProxy();

app.Run();
