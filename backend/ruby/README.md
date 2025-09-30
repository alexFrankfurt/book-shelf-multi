# Ruby Book API

A simple book API implementation in Ruby using a custom HTTP server with TCPServer.

## Prerequisites

- Ruby 3.0+

## Installation

No additional dependencies required - uses only built-in Ruby libraries.

## Running

```bash
cd backend/ruby
ruby simple_server.rb
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
  "bookId": "uuid-string",
  "title": "string",
  "author": "string",
  "description": "string (optional)",
  "coverImageUrl": "string (optional)"
}
```

## Notes

This backend requires Ruby and Bundler to be installed. On Windows, you can install Ruby using:

- Chocolatey: `choco install ruby`
- RubyInstaller: Download from https://rubyinstaller.org/

After installing Ruby, install Bundler: `gem install bundler`