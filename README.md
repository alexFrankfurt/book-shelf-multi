# Book Shelf Monorepo

This project is a monorepo containing a simple book shelf application with a separate frontend and multiple backend implementations. It is designed to demonstrate how to build the same API with different technologies and how to switch between them.

## Project Structure

The project is structured as a monorepo with the following directories:

- `frontend`: Contains the frontend application (a simple HTML file) and its tests (Cypress and Playwright).
- `backend`: Contains the different backend implementations, each in its own subdirectory:
  - `c`: A backend built with plain C using **libmicrohttpd** for HTTP requests.
  - `cpp`: A backend built with C++ using **Crow** for HTTP requests.
  - `csharp`: A backend built with ASP.NET Core using **ASP.NET Core** for HTTP requests.
  - `elixir`: A backend built with Elixir using **Plug and Cowboy** for HTTP requests.
  - `express`: A backend built with Express.js using **Express** for HTTP requests.
  - `fastapi`: A backend built with FastAPI (Python) using **FastAPI** for HTTP requests.
  - `fsharp`: A backend built with F# and ASP.NET Core using **ASP.NET Core** for HTTP requests.
  - `go`: A backend built with Go using **gorilla/mux** for HTTP requests.
  - `haskell`: A backend built with Haskell using **Scotty** for HTTP requests.
  - `idris`: A backend built with Idris 2 using **custom HTTP server** for HTTP requests.
  - `java`: A backend built with Spring Boot using **Spring Web MVC** for HTTP requests.
  - `nestjs`: A backend built with NestJS using **NestJS** (Express-based) for HTTP requests.
  - `nodejs`: A backend built with plain Node.js using **Node.js HTTP** module for HTTP requests.
  - `php`: A backend built with PHP using **built-in PHP server** for HTTP requests.
  - `ruby`: A backend built with Ruby using **custom HTTP server** for HTTP requests.
  - `rust`: A backend built with Rust using **actix-web** for HTTP requests.

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

- **Haskell:**

  ```bash
  npm run build:haskell
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

- **Haskell:**

  ```bash
  npm run start:haskell
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

- **Ruby:**

  ```bash
  npm run start:ruby
  ```

- **Elixir:**

  ```bash
  cd backend/elixir
  mix run --no-halt
  ```

- **Idris:**

  ```bash
  cd backend/idris
  idris2 --codegen chez --build app.ipkg
  ./build/exec/app
  ```

All backends run on `http://localhost:3000` by default, except:

- **NestJS:** `http://localhost:3001`
- **C++:** `http://localhost:8080`
- **Go:** `http://localhost:8081`
- **Rust:** `http://localhost:8080`
- **Java:** `http://localhost:8080`
- **C#:** `http://localhost:5000` (or `5001` for HTTPS)
- **F#:** `http://localhost:5000` (or `5001` for HTTPS)

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




