# NestJS Backend

A simple book API implementation in TypeScript using NestJS.

## Prerequisites

- Node.js 14+

## Installation

```bash
cd backend/nestjs
npm install
```

## Running

```bash
cd backend/nestjs
npm run start:dev
```

Or using npm from root:

```bash
npm run start:nestjs
```

The server will start on port 3001.

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