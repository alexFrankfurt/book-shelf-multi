# Haskell Backend

A simple book API implementation in Haskell using Scotty.

## Prerequisites

- Haskell Stack

## Installation

```bash
cd backend/haskell
stack build
```

## Running

```bash
cd backend/haskell
stack exec haskell-book-api
```

Or using npm:

```bash
npm run start:haskell
```

The server will start on port 3000.

## API Endpoints

- `GET /book` - Get all books
- `GET /book/:id` - Get a specific book by ID
- `POST /book` - Create a new book
- `PUT /book/:id` - Update a book
- `DELETE /book/:id` - Delete a book

## Book Model

```json
{
  "bookId": "string (optional)",
  "title": "string",
  "author": "string",
  "description": "string (optional)",
  "coverImageUrl": "string (optional)"
}