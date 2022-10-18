using Amazon.DynamoDBv2;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace HelloLambda.v4;

public class Startup{
    private readonly IConfigurationRoot Configuration;

    public Startup()
    {
        Configuration = new ConfigurationBuilder()
            .AddEnvironmentVariables()
            .Build();
    }

    public IServiceProvider ConfigureServices()
    {
        var services = new ServiceCollection(); 
        services.AddSingleton<IConfiguration>(Configuration);
        services.AddLogging(loggingBuilder =>
        {
            loggingBuilder.ClearProviders();
            loggingBuilder.AddConsole();
        });

        var client = new AmazonDynamoDBClient();
        services.AddSingleton<IAmazonDynamoDB>(client);
        IServiceProvider provider = services.BuildServiceProvider();

        return provider;
    }
}