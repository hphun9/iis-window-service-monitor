using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;

public class Service : BackgroundService
{
    private readonly string _logFile = Path.Combine(AppContext.BaseDirectory, "log.txt");
    private readonly HttpClient _httpClient = new HttpClient();

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            try
            {
                var response = await _httpClient.GetAsync("http://localhost");
                string logEntry = $"{timestamp} - {(int)response.StatusCode} {response.ReasonPhrase}";
                await File.AppendAllTextAsync(_logFile, logEntry + Environment.NewLine);

                if (response.StatusCode != HttpStatusCode.OK)
                {
                    await File.AppendAllTextAsync(_logFile, $"{timestamp} - Service stopping due to HTTP {response.StatusCode}" + Environment.NewLine);
                    Environment.Exit(1); // force exit
                }
            }
            catch (Exception ex)
            {
                await File.AppendAllTextAsync(_logFile, $"{timestamp} - ERROR: {ex.Message}" + Environment.NewLine);
                Environment.Exit(1);
            }

            await Task.Delay(TimeSpan.FromSeconds(60), stoppingToken);
        }
    }
}
