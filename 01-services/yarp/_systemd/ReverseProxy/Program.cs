using Serilog;
using Serilog.Events;
using Serilog.Formatting.Compact;
using Yarp.ReverseProxy.Transforms;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console(
        outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3} {SourceContext}] {Message:lj} | {Properties:j}{NewLine}{Exception}",
        applyThemeToRedirectedOutput: true)
    .WriteTo.Async(a => a
        .File(
            formatter: new CompactJsonFormatter(),
            path: "/app/yarp-logs/serilog.jsonl",
            rollingInterval: RollingInterval.Day,
            rollOnFileSizeLimit: true,
            fileSizeLimitBytes: 100 * (1 << 20), // 100 MiB
            retainedFileCountLimit: 100),
        bufferSize: 100000,
        blockWhenFull: true
    )
    .MinimumLevel.Override("Microsoft.AspNetCore.Hosting", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.Mvc", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.Routing", LogEventLevel.Warning)
    .MinimumLevel.Override("Yarp.ReverseProxy.Forwarder.HttpForwarder", LogEventLevel.Warning)
    .CreateLogger();

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddSerilog();

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

app.UseSerilogRequestLogging(options =>
{
    options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
    {
        if (httpContext.Connection.RemoteIpAddress is { } remoteIpAddress)
        {
            diagnosticContext.Set("RequestIP", remoteIpAddress);
        }
    };
});

app.MapGet("/robots.txt", () => """
    User-agent: *
    Disallow: /
    """);
app.MapReverseProxy();

try
{
    await app.RunAsync();
}
finally
{
    await Log.CloseAndFlushAsync();
}
