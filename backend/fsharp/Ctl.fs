namespace Ctl       

open System
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Cors
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting
open System.ComponentModel.DataAnnotations
open Microsoft.AspNetCore.Mvc
open Microsoft.Extensions.Logging



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
    