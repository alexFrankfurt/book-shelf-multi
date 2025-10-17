# C++ Backend

A simple book API implementation in C++ using Crow for HTTP server functionality.

## Prerequisites

- C++17 compatible compiler
- CMake 3.14+
- Crow library
- nlohmann/json library

## Building

```bash
mkdir build
cd build
cmake ..
make
```

## Running

```bash
./cpp_backend
```

Or using npm:

```bash
npm run start:cpp
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
  "id": "string",
  "title": "string",
  "author": "string",
  "published_date": "string (optional)",
  "coverImageUrl": "string"
}