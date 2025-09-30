require 'sinatra'
require 'sinatra/json'
require 'json'
require 'securerandom'

# Set port to 3000 to match other backends
set :port, 3000
set :bind, '0.0.0.0'

# Enable CORS for all routes
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
end

# Handle OPTIONS requests for CORS preflight
options '/book' do
  status 200
end

options '/book/:id' do
  status 200
end

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

# Routes

# GET /book - Get all books
get '/book' do
  content_type :json
  '[]'
end

# GET /book/:id - Get a specific book
get '/book/:id' do
  book = $books[params['id']]
  if book
    json book
  else
    status 404
    json({ error: 'Book not found' })
  end
end

# POST /book - Create a new book
post '/book' do
  request_body = JSON.parse(request.body.read)
  book = Book.new(
    request_body['title'],
    request_body['author'],
    request_body['description'],
    request_body['coverImageUrl']
  )
  $books[book.bookId] = book
  status 201
  json book
end

# PUT /book/:id - Update a book
put '/book/:id' do
  book = $books[params['id']]
  if book
    request_body = JSON.parse(request.body.read)
    book.title = request_body['title'] if request_body['title']
    book.author = request_body['author'] if request_body['author']
    book.description = request_body['description'] if request_body.key?('description')
    book.coverImageUrl = request_body['coverImageUrl'] if request_body.key?('coverImageUrl')
    json book
  else
    status 404
    json({ error: 'Book not found' })
  end
end

# DELETE /book/:id - Delete a book
delete '/book/:id' do
  if $books.delete(params['id'])
    status 204
  else
    status 404
    json({ error: 'Book not found' })
  end
end