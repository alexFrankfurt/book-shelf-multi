# Java Backend

A simple book API implementation in Java using Spring Boot.

## Prerequisites

- Java 17+
- Maven

## Running

```bash
cd backend/java
mvn spring-boot:run
```

Or using npm:

```bash
npm run start:java
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
  "description": "string (optional)",
  "coverImageUrl": "string (optional)"
}