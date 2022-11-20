using SomeScheduledJob.v1;
using Serilog;
using Serilog.Formatting.Json;

IConfiguration _configuration;

_configuration = new ConfigurationBuilder()
    .AddEnvironmentVariables()
    .Build();

IHost host = Host.CreateDefaultBuilder(args)
    .ConfigureServices(services =>
    {
        services.AddHostedService<Worker>();

        services.AddSingleton<IConfiguration>(_configuration);

    })
    .UseSerilog((hostingContext, services, loggerConfiguration) => loggerConfiguration
        .ReadFrom.Configuration(hostingContext.Configuration)
        .Enrich.FromLogContext()
        .WriteTo.Console(new JsonFormatter()))
    .Build();

await host.RunAsync();
