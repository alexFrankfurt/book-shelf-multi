# PHP Book API

A simple book API implementation in PHP using the built-in PHP development server.

## Prerequisites

- PHP 7.0+

## Installation

No additional dependencies required - uses only built-in PHP functionality.

## Running

```bash
cd backend/php
php -S 0.0.0.0:3000 index.php
```

Or using npm:

```bash
npm run start:php
```

The server will start on port 3000.

## API Endpoints

- `GET /book` - Get all books
- `GET /book/{id}` - Get a specific book by ID
- `POST /book` - Create a new book
- `PUT /book/{id}` - Update a book
- `DELETE /book/{id}` - Delete a book

## Request/Response Format

All endpoints use JSON for request and response bodies.

### Book Object
```json
{
  "bookId": "uuid-string",
  "title": "Book Title",
  "author": "Author Name",
  "description": "Book description",
  "coverImageUrl": "https://example.com/cover.jpg"
}
```

### Create/Update Book Request
```json
{
  "title": "Book Title",
  "author": "Author Name",
  "description": "Book description (optional)",
  "coverImageUrl": "Cover image URL (optional)"
}
```