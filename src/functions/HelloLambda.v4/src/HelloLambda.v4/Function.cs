using Amazon.Lambda.Core;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace HelloLambda.v4;

public class Function
{

    /// <summary>
    /// A simple function that takes a string and returns both the upper and lower case version of the string.
    /// </summary>
    /// <param name="input"></param>
    /// <param name="context"></param>
    /// <returns></returns>
    public bool FunctionHandler(Message message, ILambdaContext context)
    {
        try
        {
            if (message == null || string.IsNullOrEmpty(message.Text)) throw new ArgumentNullException(nameof(message));
            context.Logger.LogInformation($"Message is got: {message.Text})");
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