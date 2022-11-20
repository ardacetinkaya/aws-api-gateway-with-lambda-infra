using Serilog;
using Serilog.Core;

namespace SomeScheduledJob.v1;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;

    public Worker(ILogger<Worker> logger)
    {
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromSeconds(3));
        int count = 0;
        while (!stoppingToken.IsCancellationRequested
                && await timer.WaitForNextTickAsync(stoppingToken))
        {
            if (count >= 5)
            {
                await base.StopAsync(stoppingToken);
                break;
            }
            Log.Logger.Information("Worker running at: {time}", DateTimeOffset.Now);
            await Task.Delay(500, stoppingToken);
            count += 1;


        }

        Environment.Exit(0);
    }
}
