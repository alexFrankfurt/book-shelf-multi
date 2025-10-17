# F# Backend

A simple book API implementation in F# using ASP.NET Core.

## Prerequisites

- .NET 6.0 or later

## Running

```bash
cd backend/fsharp
dotnet run
```

Or using npm:

```bash
npm run start:fsharp
```

The server will start on port 5000 (or 5001 for HTTPS).

## API Endpoints

- `GET /book` - Get all books
- `GET /book/:id` - Get a specific book by ID
- `POST /book` - Create a new book
- `PUT /book/:id` - Update a book
- `DELETE /book/:id` - Delete a book

## Book Model

```json
{
  "Id": "string",
  "Title": "string",
  "Author": "string",
  "Description": "string (optional)",
  "CoverImageUrl": "string (optional)"
}