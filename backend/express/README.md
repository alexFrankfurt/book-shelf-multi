# Express.js Backend

A simple book API implementation in Node.js using Express.js.

## Prerequisites

- Node.js 14+

## Installation

```bash
cd backend/express
npm install
```

## Running

```bash
cd backend/express
npm start
```

Or using npm from root:

```bash
npm run start:express
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
  "id": "string",
  "title": "string",
  "author": "string",
  "description": "string (optional)",
  "coverImageUrl": "string (optional)"
}