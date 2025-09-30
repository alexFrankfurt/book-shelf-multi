# Alternative API Implementations

This document provides instructions on how to run the same book API implemented with different technologies.

All backends are located in the `backend` directory, each in its own subdirectory.

## Express.js Implementation

To run the Express.js implementation, use the following command from the root of the project:

```bash
npm run start:express
```

The API will be available at http://localhost:3000

## Python FastAPI Implementation

To run the FastAPI implementation, use the following command from the root of the project:

```bash
npm run start:fastapi
```

The API will be available at http://localhost:8000

Documentation will be available at:
- http://localhost:8000/docs (Swagger UI)
- http://localhost:8000/redoc (ReDoc)

## Plain Node.js Implementation

To run the plain Node.js implementation, use the following command from the root of the project:

```bash
npm run start:nodejs
```

The API will be available at http://localhost:3000

## NestJS Implementation

To run the NestJS implementation, use the following command from the root of the project:

```bash
npm run start:nestjs
```

The API will be available at http://localhost:3000

## API Data Model

All implementations use the same data model:

### Book
- `id` (string, auto-generated) - Unique identifier
- `title` (string, required) - Book title
- `author` (string, required) - Book author
- `description` (string, optional) - Book description
- `coverImageUrl` (string, optional) - URL to book cover image
