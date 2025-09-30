const http = require('http');
const url = require('url');
const { connect, createBook, findAllBooks, findBookById, updateBook, deleteBook } = require('./database');

const PORT = 3000;

// Connect to the database
connect();

// Helper function to send JSON response
const sendJsonResponse = (res, statusCode, data) => {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
    'Access-Control-Allow-Headers': 'Content-Type'
  });
  res.end(JSON.stringify(data));
};

// Helper function to parse request body
const parseBody = (req) => {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (error) {
        reject(error);
      }
    });
  });
};

// Request handler
const requestHandler = async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const method = req.method;
  const pathParts = path.split('/').filter(part => part);

  // Handle CORS preflight
  if (method === 'OPTIONS') {
    res.writeHead(200, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
    res.end();
    return;
  }

  try {
    // Route: POST /book
    if (method === 'POST' && path === '/book') {
      const body = await parseBody(req);
      
      const { title, author, description, coverImageUrl } = body;
      
      // Basic validation
      if (!title || !author) {
        return sendJsonResponse(res, 400, { error: 'Title and author are required' });
      }
      
      const newBook = await createBook({ title, author, description, coverImageUrl });
      return sendJsonResponse(res, 201, newBook);
    }

    // Route: GET /book
    if (method === 'GET' && path === '/book') {
      const books = await findAllBooks();
      return sendJsonResponse(res, 200, books);
    }

    // Route: GET /book/:id
    if (method === 'GET' && pathParts[0] === 'book' && pathParts.length === 2) {
      const id = pathParts[1];
      const book = await findBookById(id);
      
      if (!book) {
        return sendJsonResponse(res, 404, { error: `Book with ID ${id} not found` });
      }
      
      return sendJsonResponse(res, 200, book);
    }

    // Route: PUT /book/:id
    if (method === 'PUT' && pathParts[0] === 'book' && pathParts.length === 2) {
      const id = pathParts[1];
      const body = await parseBody(req);
      
      const updatedBook = await updateBook(id, body);

      if (!updatedBook) {
        return sendJsonResponse(res, 404, { error: `Book with ID ${id} not found` });
      }
      
      return sendJsonResponse(res, 200, updatedBook);
    }

    // Route: DELETE /book/:id
    if (method === 'DELETE' && pathParts[0] === 'book' && pathParts.length === 2) {
      const id = pathParts[1];
      const deleted = await deleteBook(id);
      
      if (!deleted) {
        return sendJsonResponse(res, 404, { error: `Book with ID ${id} not found` });
      }
      
      res.writeHead(204, {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
        'Access-Control-Allow-Headers': 'Content-Type'
      });
      res.end();
      return;
    }

    // 404 for unmatched routes
    sendJsonResponse(res, 404, { error: 'Route not found' });
  } catch (error) {
    sendJsonResponse(res, 500, { error: 'Internal server error' });
  }
};

const server = http.createServer(requestHandler);

server.listen(PORT, () => {
  console.log(`Plain Node.js API listening at http://localhost:${PORT}`);
});