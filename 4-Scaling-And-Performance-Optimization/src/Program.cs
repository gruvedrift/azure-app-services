var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "This is the homepage!");

app.MapGet("/cpu-intensive", (int duration = 30) =>
{
    var start = DateTime.Now;
    var end = start.AddSeconds(duration);

    // Burn CPU
    while (DateTime.Now < end)
    {
        _ = Math.Sqrt(12545 * 67890);
    }
    return $"CPU burn complete after {duration} seconds!";
});

app.Run();