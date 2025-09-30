open System
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Cors
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting
open System.ComponentModel.DataAnnotations
open Microsoft.AspNetCore.Mvc
open Microsoft.Extensions.Logging
open Ctl


// Create repository based on environment variables
let createRepository() =
    InMemoryBookRepository() :> IBookRepository


type Startup = class end


// Define the main application entry point
[<EntryPoint>]
let main argv =
    // Configure logging
    let builder = WebApplication.CreateBuilder(argv)
    
    // Add services to the container
    builder.Services.AddControllers() |> ignore
    builder.Services.AddEndpointsApiExplorer() |> ignore
    builder.Services.AddSwaggerGen() |> ignore
    builder.Logging.AddConsole() |> ignore

    // Add CORS
    builder.Services.AddCors(fun options ->
        options.AddPolicy("AllowAll", fun policy ->
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  |> ignore
        ) |> ignore
    ) |> ignore

    // Register the repository service
    let repository = createRepository()
    builder.Services.AddSingleton<IBookRepository>(repository) |> ignore

    let app = builder.Build()

    // Configure the HTTP request pipeline
    if app.Environment.IsDevelopment() then
        app.UseSwagger() |> ignore
        app.UseSwaggerUI() |> ignore

    // app.UseHttpsRedirection() |> ignore
    app.UseCors("AllowAll") |> ignore

    app.UseRouting() |> ignore


    app.UseEndpoints(fun endpoints ->
        endpoints.MapControllers() |> ignore
    )

    app.MapDefaultControllerRoute();
    let logger = app.Services.GetRequiredService<ILogger<Startup>>()

    // Log your custom message
    logger.LogInformation("🧪 Hello from main — logging works!")

    // Add a root endpoint
    app.MapGet("/", Func<string>(fun () -> "F# Book API is running on port 3000")) |> ignore

    // Log startup message
    printfn "Starting F# Book API on port 3000"

    try
        app.Run()
        0
    with ex ->
        printfn "Host terminated: %s" ex.Message
        1
