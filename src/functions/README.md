# Functions

- These are simple .NET 6 application for test purpose
- Different kind of AWS Lambda's application models are used
- New .NET project templates installed with `dotnet new --install Amazon.Lambda.Templates`

```
Template Name                                         Short Name                                    Language    Tags                                 
----------------------------------------------------  --------------------------------------------  ----------  -------------------------------------
Empty Top-level Function                              lambda.EmptyTopLevelFunction                  [C#]        AWS/Lambda/Serverless                
Lambda Annotations Framework (Preview)                serverless.Annotations                        [C#]        AWS/Lambda/Serverless                
Lambda ASP.NET Core Minimal API                       serverless.AspNetCoreMinimalAPI               [C#]        AWS/Lambda/Serverless                
Lambda ASP.NET Core Web API                           serverless.AspNetCoreWebAPI                   [C#],F#     AWS/Lambda/Serverless                
Lambda ASP.NET Core Web API (.NET 6 Container Image)  serverless.image.AspNetCoreWebAPI             [C#],F#     AWS/Lambda/Serverless                
Lambda ASP.NET Core Web Application with Razor Pages  serverless.AspNetCoreWebApp                   [C#]        AWS/Lambda/Serverless                
Lambda Custom Runtime Function (.NET 6)               lambda.CustomRuntimeFunction                  [C#],F#     AWS/Lambda/Function                  
Lambda Detect Image Labels                            lambda.DetectImageLabels                      [C#],F#     AWS/Lambda/Function                  
Lambda Empty Function                                 lambda.EmptyFunction                          [C#],F#     AWS/Lambda/Function                  
Lambda Empty Function (.NET 6 Container Image)        lambda.image.EmptyFunction                    [C#],F#     AWS/Lambda/Function                  
Lambda Empty Serverless                               serverless.EmptyServerless                    [C#],F#     AWS/Lambda/Serverless                
Lambda Empty Serverless (.NET 6 Container Image)      serverless.image.EmptyServerless              [C#],F#     AWS/Lambda/Serverless                
Lambda Giraffe Web App                                serverless.Giraffe                            F#          AWS/Lambda/Serverless                
Lambda Simple Application Load Balancer Function      lambda.SimpleApplicationLoadBalancerFunction  [C#]        AWS/Lambda/Function                  
Lambda Simple DynamoDB Function                       lambda.DynamoDB                               [C#],F#     AWS/Lambda/Function                  
Lambda Simple Kinesis Firehose Function               lambda.KinesisFirehose                        [C#]        AWS/Lambda/Function                  
Lambda Simple Kinesis Function                        lambda.Kinesis                                [C#],F#     AWS/Lambda/Function                  
Lambda Simple S3 Function                             lambda.S3                                     [C#],F#     AWS/Lambda/Function                  
Lambda Simple SNS Function                            lambda.SNS                                    [C#]        AWS/Lambda/Function                  
Lambda Simple SQS Function                            lambda.SQS                                    [C#]        AWS/Lambda/Function                  
Lex Book Trip Sample                                  lambda.LexBookTripSample                      [C#]        AWS/Lambda/Function                  
Order Flowers Chatbot Tutorial                        lambda.OrderFlowersChatbot                    [C#]        AWS/Lambda/Function                  
Serverless Detect Image Labels                        serverless.DetectImageLabels                  [C#],F#     AWS/Lambda/Serverless                
Serverless Simple S3 Function                         serverless.S3                                 [C#],F#     AWS/Lambda/Serverless                
Serverless WebSocket API                              serverless.WebSocketAPI                       [C#]        AWS/Lambda/Serverless                
Step Functions Hello World                            serverless.StepFunctionsHelloWorld            [C#],F#     AWS/Lambda/Serverless                
```

- HelloLambda.v1: `dotnet new  webapi -n HelloLambda.v1`
- HelloLambda.v2: `dotnet new  serverless.image.AspNetCoreWebAPI -n HelloLambda.v2`
- HelloLambda.v3: `dotnet new  serverless.image.EmptyServerless -n HelloLambda.v3`