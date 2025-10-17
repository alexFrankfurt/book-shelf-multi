# Go Backend

A simple book API implementation in Go using Gorilla Mux.

## Prerequisites

- Go 1.16+

## Running

```bash
cd backend/go
go run main.go
```

Or using npm:

```bash
npm run start:go
```

The server will start on port 8081.

## API Endpoints

- `GET /book` - Get all books
- `GET /book/:id` - Get a specific book by ID
- `POST /book` - Create a new book
- `PUT /book/:id` - Update a book
- `DELETE /book/:id` - Delete a book

## Book Model

```json
{
  "ID": "string",
  "Title": "string",
  "Author": "string",
  "PublishedDate": "string (optional)",
  "CoverImageUrl": "string"
}