using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Amazon.Lambda.Core;
using Amazon.Runtime;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace HelloLambda.v4;

public class Function
{
    private readonly IAmazonDynamoDB _client;
    private readonly DynamoDBContext _context;
    private readonly ILogger _logger;

    public Function()
    {
        var startup = new Startup();
        IServiceProvider provider = startup.ConfigureServices();

        _client = provider.GetRequiredService<IAmazonDynamoDB>();
        _logger = provider.GetRequiredService<ILogger>();
        _context = new DynamoDBContext(_client);
    }
    /// <summary>
    /// A simple function that takes a string and returns both the upper and lower case version of the string.
    /// </summary>
    /// <param name="input"></param>
    /// <param name="context"></param>
    /// <returns></returns>
    public async Task<bool> FunctionHandler(Message message, ILambdaContext context)
    {
        try
        {
            if (message == null || string.IsNullOrEmpty(message.Text)) throw new ArgumentNullException(nameof(message));
            context.Logger.LogInformation($"Message is got: {message.Text})");
            await _context.SaveAsync<MessageData>(new MessageData{
                Text = message.Text.Trim()
            });
            context.Logger.LogInformation($"Message is saved.");
            return true;
        }
        catch (System.Exception ex)
        {
            context.Logger.LogError(ex.Message);
            return true;
        }

    }
}

public class Message
{
    public string? Text { get; set; }
}

[DynamoDBTable("Messages")]
public class MessageData
{
    public Guid Id { get; private set; } = Guid.NewGuid();
    public string? Text { get; set; }
    public DateTime Date { get; set; } = DateTime.UtcNow;
}