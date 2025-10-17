# C# Backend

A simple book API implementation in C# using ASP.NET Core.

## Prerequisites

- .NET 6.0 or later

## Running

```bash
cd backend/csharp
dotnet run
```

Or using npm:

```bash
npm run start:csharp
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
  "id": "string",
  "title": "string",
  "author": "string",
  "description": "string (optional)",
  "coverImageUrl": "string (optional)"
}