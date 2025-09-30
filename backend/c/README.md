# Plain C Backend

This is a plain C implementation of the Book API using the GNU libmicrohttpd library for HTTP server functionality.

## Dependencies

This implementation requires the following libraries:

- **libmicrohttpd**: A small C library for embedding HTTP server functionality
- **json-c**: A JSON implementation in C
- **libuuid**: For generating unique identifiers

### Installing Dependencies

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install libmicrohttpd-dev libjson-c-dev uuid-dev build-essential
```

#### Fedora/RHEL:
```bash
sudo dnf install libmicrohttpd-devel json-c-devel libuuid-devel gcc make
```

#### macOS (using Homebrew):
```bash
brew install libmicrohttpd json-c ossp-uuid
```

#### Windows (using MSYS2):
```bash
pacman -S mingw-w64-x86_64-libmicrohttpd mingw-w64-x86_64-json-c mingw-w64-x86_64-gcc
```

## Building

To build the application, run:

```bash
make
```

This will compile all source files and create the `book-api` executable.

## Running

To run the server:

```bash
make run
```

Or directly:

```bash
./book-api
```

The API will be available at http://localhost:3000

To stop the server, press Enter in the terminal where it's running.

## API Endpoints

The C backend implements the same REST API as other implementations:

- `GET /book` - Get all books
- `GET /book/:id` - Get a specific book by ID
- `POST /book` - Create a new book
- `PUT /book/:id` - Update a book
- `DELETE /book/:id` - Delete a book

### Example Usage

```bash
# Create a book
curl -X POST http://localhost:3000/book \
  -H "Content-Type: application/json" \
  -d '{"title":"The C Programming Language","author":"Brian Kernighan and Dennis Ritchie","description":"Classic C programming book"}'

# Get all books
curl http://localhost:3000/book

# Get a specific book
curl http://localhost:3000/book/{id}

# Update a book
curl -X PUT http://localhost:3000/book/{id} \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated Title"}'

# Delete a book
curl -X DELETE http://localhost:3000/book/{id}
```

## Features

- In-memory storage (no database dependencies by default)
- CORS support for cross-origin requests
- JSON request/response handling
- UUID generation for book IDs
- Full CRUD operations

## Code Structure

- `main.c` - HTTP server and routing logic
- `book.c/book.h` - Book data model and CRUD operations
- `json.c/json.h` - JSON serialization/deserialization
- `Makefile` - Build configuration

## Cleaning Up

To remove compiled files:

```bash
make clean
```
