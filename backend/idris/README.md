# Idris Backend

A simple book API implementation in Idris 2.

## Prerequisites

- Idris 2

## Building

```bash
cd backend/idris
idris2 --codegen chez --build app.ipkg
```

## Running

```bash
cd backend/idris
./build/exec/app
```

The server will start on port 3000.

## API Endpoints

- `GET /books` - Get all books
- `GET /books/:id` - Get a specific book by ID
- `POST /books` - Create a new book
- `PUT /books/:id` - Update a book
- `DELETE /books/:id` - Delete a book

## Book Model

```json
{
  "id": "number",
  "title": "string",
  "author": "string",
  "description": "string",
  "coverImageUrl": "string"
}