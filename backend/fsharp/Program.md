open System
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Cors
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting
open System.ComponentModel.DataAnnotations
open Microsoft.AspNetCore.Mvc
open Microsoft.Extensions.Logging


// Define the Book record type
type Book = {
    Id: string
    Title: string
    Author: string
    Description: string option
    CoverImageUrl: string option
}

// Define DTOs for create and update operations
type CreateBookDto = {
    [<Required>]
    Title: string
    [<Required>]
    Author: string
    Description: string option
    CoverImageUrl: string option
}

type UpdateBookDto = {
    Title: string option
    Author: string option
    Description: string option
    CoverImageUrl: string option
}

// Database interface for different implementations
type IBookRepository = 
    abstract CreateBook: CreateBookDto -> Book
    abstract FindAllBooks: unit -> Book list
    abstract FindBookById: string -> Book option
    abstract UpdateBook: (string * UpdateBookDto) -> Book option
    abstract DeleteBook: string -> bool

// In-memory repository implementation
type InMemoryBookRepository() =
    let books = System.Collections.Concurrent.ConcurrentDictionary<string, Book>()
    
    interface IBookRepository with
        member this.CreateBook(dto) = 
            let id = Guid.NewGuid().ToString()
            let book = {
                Id = id
                Title = dto.Title
                Author = dto.Author
                Description = dto.Description
                CoverImageUrl = dto.CoverImageUrl
            }
            books.[id] <- book
            book
        
        member this.FindAllBooks() = 
            books.Values |> Seq.toList
        
        member this.FindBookById(id) = 
            match books.TryGetValue(id) with
            | true, book -> Some book
            | false, _ -> None
        
        member this.UpdateBook((id, updates)) = 
            match books.TryGetValue(id) with
            | true, book ->
                let updatedBook = {
                    book with
                        Title = match updates.Title with Some t -> t | None -> book.Title
                        Author = match updates.Author with Some a -> a | None -> book.Author
                        Description = match updates.Description with Some d -> Some d | None -> book.Description
                        CoverImageUrl = match updates.CoverImageUrl with Some url -> Some url | None -> book.CoverImageUrl
                }
                books.[id] <- updatedBook
                Some updatedBook
            | false, _ -> None
        
        member this.DeleteBook(id) = 
            books.TryRemove(id) |> ignore
            true  // We assume deletion was successful if the book existed


// BookController to handle API endpoints
[<ApiController>]
[<Route("book")>]
type public BookController(bookRepository: IBookRepository) =
    inherit ControllerBase()
    
    [<HttpGet>]
    member this.GetAllBooks() : IActionResult = 
        this.Ok(bookRepository.FindAllBooks()) :> IActionResult
    
    [<HttpGet("{id}")>]
    member this.GetBookById(id: string) : IActionResult = 
        match bookRepository.FindBookById(id) with
        | Some book -> this.Ok(book) :> IActionResult
        | None -> this.NotFound(sprintf "Book with ID %s not found" id) :> IActionResult
    
    [<HttpPost>]
    member this.CreateBook([<FromBody>] dto: CreateBookDto) : IActionResult = 
        if String.IsNullOrWhiteSpace(dto.Title) || String.IsNullOrWhiteSpace(dto.Author) then
            this.BadRequest("Title and author are required") :> IActionResult
        else
            let book = bookRepository.CreateBook(dto)
            this.CreatedAtAction("GetBookById", {| id = book.Id |}, book) :> IActionResult
    
    [<HttpPut("{id}")>]
    member this.UpdateBook(id: string, [<FromBody>] dto: UpdateBookDto) : IActionResult = 
        match bookRepository.UpdateBook(id, dto) with
        | Some book -> this.Ok(book) :> IActionResult
        | None -> this.NotFound(sprintf "Book with ID %s not found" id) :> IActionResult
    
    [<HttpDelete("{id}")>]
    member this.DeleteBook(id: string) : IActionResult = 
        if bookRepository.DeleteBook(id) then
            this.NoContent() :> IActionResult
        else
            this.NotFound(sprintf "Book with ID %s not found" id) :> IActionResult

// Create repository based on environment variables
let createRepository() =
    InMemoryBookRepository() :> IBookRepository


type DummyController() =
    inherit ControllerBase()

    [<HttpGet>]
    [<Route("ping")>]
    member _.Ping() : IActionResult =
        base.Ok("pong")


[<ApiController>]
[<Route("whatever")>]
type WhateverController() =
    inherit ControllerBase()

    [<HttpGet>]
    member _.Get() : IActionResult =
        base.Ok("Hello from /whatever")

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
