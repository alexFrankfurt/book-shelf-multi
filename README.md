# Book Shelf Monorepo

This project is a monorepo containing a simple book shelf application with a separate frontend and multiple backend implementations. It is designed to demonstrate how to build the same API with different technologies and how to switch between them.

## Project Structure

The project is structured as a monorepo with the following directories:

- `frontend`: Contains the frontend application (a simple HTML file) and its tests (Cypress and Playwright).
- `backend`: Contains the different backend implementations, each in its own subdirectory:
  - `c`: A backend built with plain C.
  - `cpp`: A backend built with C++.
  - `csharp`: A backend built with ASP.NET Core.
  - `express`: A backend built with Express.js.
  - `fastapi`: A backend built with FastAPI (Python).
  - `fsharp`: A backend built with F# and ASP.NET Core.
  - `go`: A backend built with Go.
  - `java`: A backend built with Spring Boot.
  - `nestjs`: A backend built with NestJS.
  - `nodejs`: A backend built with plain Node.js.
  - `rust`: A backend built with Rust.

## Installation

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   ```

2. **Install dependencies for all workspaces:**

   ```bash
   npm install
   ```

   This will install the dependencies for the root project, the frontend, and all the backend projects.

## Building Backends

Some backends require building before running:

- **Plain C:**

  ```bash
  npm run build:c
  ```

- **C++:**

  ```bash
  npm run build:cpp
  ```

- **Rust:**

  ```bash
  npm run build:rust
  ```

## Running the Application

### Frontend

To run the frontend, use the following command:

```bash
npm run start:frontend
```

This will start a simple HTTP server to serve the `frontend/public/index.html` file at `http://localhost:8080`.

### Backends

You can run any of the backend implementations using the following commands:

- **NestJS:**

  ```bash
  npm run start:nestjs
  ```

- **Express:**

  ```bash
  npm run start:express
  ```

- **FastAPI:**

  ```bash
  npm run start:fastapi
  ```

- **Node.js:**

  ```bash
  npm run start:nodejs
  ```

- **Plain C:**

  ```bash
  npm run start:c
  ```

- **C++:**

  ```bash
  npm run start:cpp
  ```

- **Go:**

  ```bash
  npm run start:go
  ```

- **Rust:**

  ```bash
  npm run start:rust
  ```

- **Java:**

  ```bash
  npm run start:java
  ```

- **C#:**

  ```bash
  npm run start:csharp
  ```

- **F#:**

  ```bash
  npm run start:fsharp
  ```

All backends run on `http://localhost:3000` by default.

## Database Configuration

Each backend can be configured to use either MongoDB or OracleDB for data persistence. This is controlled by the `DB_TYPE` environment variable.

- `DB_TYPE=mongodb`: Use MongoDB.
- `DB_TYPE=oracledb`: Use OracleDB.

You also need to provide the connection details as environment variables:

- **MongoDB:**

  - `MONGO_URI`: The connection string for your MongoDB database.

- **OracleDB:**

  - `ORACLE_USER`: The database user.
  - `ORACLE_PASSWORD`: The user's password.
  - `ORACLE_CONNECTION_STRING`: The connection string for your Oracle database.
  - `ORACLE_LIB_DIR` (optional): The path to your Oracle client libraries if you are not using the Thin mode.

If `DB_TYPE` is not set, the backends will use in-memory storage.

## Running Tests

The project has two sets of end-to-end tests: Cypress and Playwright.

- **Cypress:**

  ```bash
  npm run test:cypress
  ```

- **Playwright:**

  ```bash
  npm run test:playwright
  ```

Both test runners are configured to run against the frontend application, which in turn communicates with the backend running on `http://localhost:3000`.