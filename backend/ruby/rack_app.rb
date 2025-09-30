require 'json'
require 'securerandom'

# In-memory book storage
$books = {}

# Book class
class Book
  attr_accessor :bookId, :title, :author, :description, :coverImageUrl

  def initialize(title, author, description = nil, coverImageUrl = nil, bookId = nil)
    @bookId = bookId || SecureRandom.uuid
    @title = title
    @author = author
    @description = description
    @coverImageUrl = coverImageUrl
  end

  def to_json(*args)
    {
      bookId: @bookId,
      title: @title,
      author: @author,
      description: @description,
      coverImageUrl: @coverImageUrl
    }.to_json(*args)
  end
end

# CORS headers
CORS_HEADERS = {
  'Access-Control-Allow-Origin' => '*',
  'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers' => 'Content-Type'
}

# Rack application
class BookApp
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    # Add CORS headers
    CORS_HEADERS.each { |k, v| res[k] = v }

    case [req.request_method, req.path]
    when ['GET', '/book']
      # Get all books
      books_array = $books.values
      res['Content-Type'] = 'application/json'
      res.write(books_array.to_json)
      res.status = 200

    when ['GET', /^\/book\/(.+)$/]
      # Get specific book
      book_id = $1
      book = $books[book_id]
      if book
        res['Content-Type'] = 'application/json'
        res.write(book.to_json)
        res.status = 200
      else
        res['Content-Type'] = 'application/json'
        res.write({ error: 'Book not found' }.to_json)
        res.status = 404
      end

    when ['POST', '/book']
      # Create book
      begin
        data = JSON.parse(req.body.read)
        book = Book.new(data['title'], data['author'], data['description'], data['coverImageUrl'])
        $books[book.bookId] = book
        res['Content-Type'] = 'application/json'
        res.write(book.to_json)
        res.status = 201
      rescue JSON::ParserError
        res['Content-Type'] = 'application/json'
        res.write({ error: 'Invalid JSON' }.to_json)
        res.status = 400
      end

    when ['PUT', /^\/book\/(.+)$/]
      # Update book
      book_id = $1
      book = $books[book_id]
      if book
        begin
          data = JSON.parse(req.body.read)
          book.title = data['title'] if data['title']
          book.author = data['author'] if data['author']
          book.description = data['description'] if data.key?('description')
          book.coverImageUrl = data['coverImageUrl'] if data.key?('coverImageUrl')
          res['Content-Type'] = 'application/json'
          res.write(book.to_json)
          res.status = 200
        rescue JSON::ParserError
          res['Content-Type'] = 'application/json'
          res.write({ error: 'Invalid JSON' }.to_json)
          res.status = 400
        end
      else
        res['Content-Type'] = 'application/json'
        res.write({ error: 'Book not found' }.to_json)
        res.status = 404
      end

    when ['DELETE', /^\/book\/(.+)$/]
      # Delete book
      book_id = $1
      if $books.delete(book_id)
        res.status = 204
      else
        res['Content-Type'] = 'application/json'
        res.write({ error: 'Book not found' }.to_json)
        res.status = 404
      end

    when ['OPTIONS', '/book'], ['OPTIONS', /^\/book\/(.+)$/]
      # CORS preflight
      res.status = 200

    else
      res['Content-Type'] = 'application/json'
      res.write({ error: 'Not found' }.to_json)
      res.status = 404
    end

    res.finish
  end
end