const express = require('express');
const cors = require('cors');
const { connect, createBook, findAllBooks, findBookById, updateBook, deleteBook } = require('./database');

const app = express();
const port = 3000;

// Middleware to parse JSON bodies
app.use(express.json());
app.use(cors());

// Connect to the database
connect();

// Create a book
app.post('/book', async (req, res) => {
  const { title, author, description, coverImageUrl } = req.body;
  
  // Basic validation
  if (!title || !author) {
    return res.status(400).json({ error: 'Title and author are required' });
  }
  
  const newBook = await createBook({ title, author, description, coverImageUrl });
  res.status(201).json(newBook);
});

// Get all books
app.get('/book', async (req, res) => {
  const books = await findAllBooks();
  res.json(books);
});

// Get a specific book
app.get('/book/:id', async (req, res) => {
  const { id } = req.params;
  const book = await findBookById(id);
  
  if (!book) {
    return res.status(404).json({ error: `Book with ID ${id} not found` });
  }
  
  res.json(book);
});

// Update a book
app.put('/book/:id', async (req, res) => {
  const { id } = req.params;
  const updateData = req.body;
  
  const updatedBook = await updateBook(id, updateData);
  
  if (!updatedBook) {
    return res.status(404).json({ error: `Book with ID ${id} not found` });
  }
  
  res.json(updatedBook);
});

// Delete a book
app.delete('/book/:id', async (req, res) => {
  const { id } = req.params;
  const deleted = await deleteBook(id);
  
  if (!deleted) {
    return res.status(404).json({ error: `Book with ID ${id} not found` });
  }
  
  res.status(204).send();
});

app.listen(port, () => {
  console.log(`Express API listening at http://localhost:${port}`);
});