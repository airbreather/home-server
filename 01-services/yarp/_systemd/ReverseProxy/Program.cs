using Serilog;
using Serilog.Events;
using Serilog.Formatting.Compact;
using Serilog.Templates;
using Serilog.Templates.Themes;
using Yarp.ReverseProxy.Transforms;

Log.Logger = new LoggerConfiguration()
    .Filter.ByExcluding("RequestPath = '/api/actions/runner.v1.RunnerService/FetchTask'")
    .WriteTo.Console(
        formatter: new ExpressionTemplate(
            "[{@t:HH:mm:ss} {@l:u3} {SourceContext}] {@m}{#if rest(true) <> {}} | {rest(true)}{#end}\n{Exception}",
            theme: TemplateTheme.Literate,
            applyThemeWhenOutputIsRedirected: true
        ))
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
        diagnosticContext.Set("RequestHost", httpContext.Request.Host);
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
