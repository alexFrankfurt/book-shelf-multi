describe('Book Shelf App', () => {
  let books = [];

  beforeEach(() => {
    books = [];
    cy.intercept('GET', '/book', (req) => {
      req.reply(books);
    }).as('getBooks');
    cy.intercept('POST', '/book', (req) => {
      const newBook = req.body;
      newBook.id = Math.random().toString();
      books.push(newBook);
      req.reply({ statusCode: 201 });
    }).as('addBook');
    cy.intercept('GET', '/book/*', (req) => {
        const id = req.url.split('/').pop();
        const book = books.find(b => b.id === id);
        if (book) {
            req.reply(book);
        } else {
            req.reply({ statusCode: 404 });
        }
    }).as('getBook');
    cy.intercept('PUT', '/book/*', (req) => {
      const id = req.url.split('/').pop();
      const updatedBook = req.body;
      const bookIndex = books.findIndex(b => b.id === id);
      if (bookIndex !== -1) {
        books[bookIndex] = { ...books[bookIndex], ...updatedBook };
        req.reply({ statusCode: 200 });
      } else {
        req.reply({ statusCode: 404 });
      }
    }).as('updateBook');
    cy.intercept('DELETE', '/book/*', (req) => {
      const id = req.url.split('/').pop();
      const bookIndex = books.findIndex(b => b.id === id);
      if (bookIndex !== -1) {
        books.splice(bookIndex, 1);
        req.reply({ statusCode: 200 });
      } else {
        req.reply({ statusCode: 404 });
      }
    }).as('deleteBook');
  });

  it('should display the main heading', () => {
    cy.visit('/');
    cy.get('h1').should('contain', 'Book Shelf');
  });

  it('should display the add new book form', () => {
    cy.visit('/');
    cy.get('#addBookForm').should('be.visible');
    cy.contains('h2', 'Add New Book').should('be.visible');
  });

  it('should display the my books section', () => {
    books.push({ id: '1', title: 'The Lord of the Rings', author: 'J.R.R. Tolkien', description: 'A fantasy novel.', coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51EstVXM1UL._SX331_BO1,204,203,200_.jpg' });
    cy.visit('/');
    cy.wait('@getBooks');
    cy.get('h2').should('contain', 'My Books');
    cy.get('#bookList').should('be.visible');
    cy.get('.book-card').should('have.length', 1);
  });

  it('should add a new book', () => {
    cy.visit('/');
    cy.wait('@getBooks');

    const newBook = {
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      description: 'A novel about the American dream.',
      coverImageUrl: 'https://images.penguinrandomhouse.com/cover/9780743273565'
    };

    cy.get('#title').type(newBook.title);
    cy.get('#author').type(newBook.author);
    cy.get('#description').type(newBook.description);
    cy.get('#coverImageUrl').type(newBook.coverImageUrl);
    cy.get('#addBookForm button[type="submit"]').click();

    cy.wait('@addBook');
    cy.wait('@getBooks');

    cy.get('#bookList').should('contain', newBook.title);
  });

  it('should edit a book', () => {
    const initialBook = { id: '1', title: 'The Lord of the Rings', author: 'J.R.R. Tolkien', description: 'A fantasy novel.', coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51EstVXM1UL._SX331_BO1,204,203,200_.jpg' };
    books.push(initialBook);
    const updatedTitle = 'The Hobbit';

    cy.visit('/');
    cy.wait('@getBooks');

    cy.get('.book-card[data-id="1"] .edit-btn').click();
    cy.wait('@getBook');

    cy.get('#editCoverImageUrl').should('have.value', initialBook.coverImageUrl);

    cy.get('#editTitle').clear().type(updatedTitle);
    cy.get('#editBookForm button[type="submit"]').click();
    cy.wait('@updateBook');
    cy.wait('@getBooks');

    cy.get('.book-card[data-id="1"] .card-title').should('contain', updatedTitle);
  });

  it('should delete a book', () => {
    const initialBook = { id: '1', title: 'The Lord of the Rings', author: 'J.R.R. Tolkien', description: 'A fantasy novel.', coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51EstVXM1UL._SX331_BO1,204,203,200_.jpg' };
    books.push(initialBook);

    cy.visit('/');
    cy.wait('@getBooks');

    cy.get('.book-card[data-id="1"] .delete-btn').click();
    cy.wait('@deleteBook');
    cy.wait('@getBooks');

    cy.get('.book-card[data-id="1"]').should('not.exist');
  });
});
