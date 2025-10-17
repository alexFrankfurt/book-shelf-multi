# Rust Backend

A simple book API implementation in Rust using Actix Web.

## Prerequisites

- Rust 1.70+

## Running

```bash
cd backend/rust
cargo run
```

Or using npm:

```bash
npm run start:rust
```

The server will start on port 8080.

## API Endpoints

- `GET /book` - Get all books
- `GET /book/:id` - Get a specific book by ID
- `POST /book` - Create a new book
- `PUT /book/:id` - Update a book
- `DELETE /book/:id` - Delete a book

## Book Model

```json
{
  "id": "string (optional)",
  "title": "string",
  "author": "string",
  "published_date": "string (optional)",
  "coverImageUrl": "string"
}