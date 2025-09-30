const { MongoClient } = require('mongodb');
const oracledb = require('oracledb');
const { v4: uuidv4 } = require('uuid');

const dbType = process.env.DB_TYPE;

let db = {};

async function connect() {
  if (dbType === 'mongodb') {
    const client = new MongoClient(process.env.MONGO_URI);
    await client.connect();
    db.client = client;
    db.collection = client.db().collection('books');
  } else if (dbType === 'oracledb') {
    if (process.env.ORACLE_LIB_DIR) {
        oracledb.initOracleClient({ libDir: process.env.ORACLE_LIB_DIR });
    }
    db.connection = await oracledb.getConnection({
      user: process.env.ORACLE_USER,
      password: process.env.ORACLE_PASSWORD,
      connectionString: process.env.ORACLE_CONNECTION_STRING,
    });
    // Auto-commit for simplicity in this example
    db.connection.autoCommit = true;
    await ensureTableExists(db.connection);
  } else {
    // In-memory
    db.books = [];
  }
}

async function ensureTableExists(connection) {
  try {
    await connection.execute(
      `CREATE TABLE books (
        id VARCHAR2(36) PRIMARY KEY,
        title VARCHAR2(255) NOT NULL,
        author VARCHAR2(255) NOT NULL,
        description VARCHAR2(4000),
        coverImageUrl VARCHAR2(2048)
      )`
    );
  } catch (error) {
    // ORA-00955: name is already used by an existing object - table already exists
    if (error.errorNum !== 955) {
      throw error;
    }
  }
}

async function createBook(book) {
    const id = uuidv4();
    const newBook = { id, ...book };

    if (dbType === 'mongodb') {
        const result = await db.collection.insertOne(newBook);
        return newBook;
    } else if (dbType === 'oracledb') {
        await db.connection.execute(
            `INSERT INTO books (id, title, author, description, coverImageUrl) VALUES (:id, :title, :author, :description, :coverImageUrl)`,
            [id, newBook.title, newBook.author, newBook.description, newBook.coverImageUrl]
        );
        return newBook;
    } else {
        db.books.push(newBook);
        return newBook;
    }
}

async function findAllBooks() {
    if (dbType === 'mongodb') {
        return db.collection.find({}).toArray();
    } else if (dbType === 'oracledb') {
        const result = await db.connection.execute('SELECT * FROM books');
        return result.rows;
    } else {
        return db.books;
    }
}

async function findBookById(id) {
    if (dbType === 'mongodb') {
        return db.collection.findOne({ id: id });
    } else if (dbType === 'oracledb') {
        const result = await db.connection.execute('SELECT * FROM books WHERE id = :id', [id]);
        return result.rows[0];
    } else {
        return db.books.find(book => book.id === id);
    }
}

async function updateBook(id, updates) {
    if (dbType === 'mongodb') {
        const result = await db.collection.findOneAndUpdate({ id: id }, { $set: updates }, { returnDocument: 'after' });
        return result.value;
    } else if (dbType === 'oracledb') {
        const book = await findBookById(id);
        const updatedBook = { ...book, ...updates };
        await db.connection.execute(
            `UPDATE books SET title = :title, author = :author, description = :description, coverImageUrl = :coverImageUrl WHERE id = :id`,
            [updatedBook.title, updatedBook.author, updatedBook.description, updatedBook.coverImageUrl, id]
        );
        return updatedBook;
    } else {
        const index = db.books.findIndex(book => book.id === id);
        if (index === -1) {
            return null;
        }
        db.books[index] = { ...db.books[index], ...updates };
        return db.books[index];
    }
}

async function deleteBook(id) {
    if (dbType === 'mongodb') {
        const result = await db.collection.deleteOne({ id: id });
        return result.deletedCount > 0;
    } else if (dbType === 'oracledb') {
        const result = await db.connection.execute('DELETE FROM books WHERE id = :id', [id]);
        return result.rowsAffected > 0;
    } else {
        const initialLength = db.books.length;
        db.books = db.books.filter(book => book.id !== id);
        return db.books.length < initialLength;
    }
}

module.exports = { connect, createBook, findAllBooks, findBookById, updateBook, deleteBook, db };
