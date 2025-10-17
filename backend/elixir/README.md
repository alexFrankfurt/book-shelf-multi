# BookShelf API (Elixir)

A simple REST API for managing books, implemented in Elixir using Plug and Cowboy.

## Endpoints

- `GET /book` - Get all books
- `GET /book/:id` - Get a specific book
- `POST /book` - Create a new book
- `PUT /book/:id` - Update a book
- `DELETE /book/:id` - Delete a book

## Running

1. Install dependencies: `mix deps.get`
2. Start the server: `mix run --no-halt`

The server will run on port 3000.