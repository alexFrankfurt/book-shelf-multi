require 'socket'
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

  def to_hash
    {
      bookId: @bookId,
      title: @title,
      author: @author,
      description: @description,
      coverImageUrl: @coverImageUrl
    }
  end
end

# Simple HTTP server
server = TCPServer.new('0.0.0.0', 3000)
puts "Ruby Book API server running on port 3000..."

loop do
  begin
    client = server.accept
    request_line = client.gets
    next unless request_line

    # Parse request
    method, path, version = request_line.split

    # Read headers
    headers = {}
    while (line = client.gets) && line != "\r\n"
      key, value = line.split(': ', 2)
      headers[key] = value&.strip
    end

    # Read body if present
    body = ""
    if headers['Content-Length']
      body = client.read(headers['Content-Length'].to_i)
    end

    # CORS headers
    cors_headers = [
      "Access-Control-Allow-Origin: *",
      "Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS",
      "Access-Control-Allow-Headers: Content-Type"
    ]

    response = ""

    # Handle requests
    if method == 'GET' && path == '/book'
      # Get all books
      books_array = $books.values.map(&:to_hash)
      response_body = books_array.to_json
      response = "HTTP/1.1 200 OK\r\n"
      cors_headers.each { |h| response += "#{h}\r\n" }
      response += "Content-Type: application/json\r\n"
      response += "Content-Length: #{response_body.bytesize}\r\n"
      response += "\r\n"
      response += response_body

    elsif method == 'GET' && path =~ /^\/book\/(.+)$/
      # Get specific book
      book_id = $1
      book = $books[book_id]
      if book
        response_body = book.to_hash.to_json
        response = "HTTP/1.1 200 OK\r\n"
        cors_headers.each { |h| response += "#{h}\r\n" }
        response += "Content-Type: application/json\r\n"
        response += "Content-Length: #{response_body.bytesize}\r\n"
        response += "\r\n"
        response += response_body
      else
        response_body = { error: 'Book not found' }.to_json
        response = "HTTP/1.1 404 Not Found\r\n"
        cors_headers.each { |h| response += "#{h}\r\n" }
        response += "Content-Type: application/json\r\n"
        response += "Content-Length: #{response_body.bytesize}\r\n"
        response += "\r\n"
        response += response_body
      end

    elsif method == 'POST' && path == '/book'
      # Create book
      begin
        data = JSON.parse(body)
        book = Book.new(data['title'], data['author'], data['description'], data['coverImageUrl'])
        $books[book.bookId] = book
        response_body = book.to_hash.to_json
        response = "HTTP/1.1 201 Created\r\n"
        cors_headers.each { |h| response += "#{h}\r\n" }
        response += "Content-Type: application/json\r\n"
        response += "Content-Length: #{response_body.bytesize}\r\n"
        response += "\r\n"
        response += response_body
      rescue JSON::ParserError
        response_body = { error: 'Invalid JSON' }.to_json
        response = "HTTP/1.1 400 Bad Request\r\n"
        cors_headers.each { |h| response += "#{h}\r\n" }
        response += "Content-Type: application/json\r\n"
        response += "Content-Length: #{response_body.bytesize}\r\n"
        response += "\r\n"
        response += response_body
      end

    elsif method == 'PUT' && path =~ /^\/book\/(.+)$/
      # Update book
      book_id = $1
      book = $books[book_id]
      if book
        begin
          data = JSON.parse(body)
          book.title = data['title'] if data['title']
          book.author = data['author'] if data['author']
          book.description = data['description'] if data.key?('description')
          book.coverImageUrl = data['coverImageUrl'] if data.key?('coverImageUrl')
          response_body = book.to_hash.to_json
          response = "HTTP/1.1 200 OK\r\n"
          cors_headers.each { |h| response += "#{h}\r\n" }
          response += "Content-Type: application/json\r\n"
          response += "Content-Length: #{response_body.bytesize}\r\n"
          response += "\r\n"
          response += response_body
        rescue JSON::ParserError
          response_body = { error: 'Invalid JSON' }.to_json
          response = "HTTP/1.1 400 Bad Request\r\n"
          cors_headers.each { |h| response += "#{h}\r\n" }
          response += "Content-Type: application/json\r\n"
          response += "Content-Length: #{response_body.bytesize}\r\n"
          response += "\r\n"
          response += response_body
        end
      else
        response_body = { error: 'Book not found' }.to_json
        response = "HTTP/1.1 404 Not Found\r\n"
        cors_headers.each { |h| response += "#{h}\r\n" }
        response += "Content-Type: application/json\r\n"
        response += "Content-Length: #{response_body.bytesize}\r\n"
        response += "\r\n"
        response += response_body
      end

    elsif method == 'DELETE' && path =~ /^\/book\/(.+)$/
      # Delete book
      book_id = $1
      if $books.delete(book_id)
        response = "HTTP/1.1 204 No Content\r\n"
        cors_headers.each { |h| response += "#{h}\r\n" }
        response += "\r\n"
      else
        response_body = { error: 'Book not found' }.to_json
        response = "HTTP/1.1 404 Not Found\r\n"
        cors_headers.each { |h| response += "#{h}\r\n" }
        response += "Content-Type: application/json\r\n"
        response += "Content-Length: #{response_body.bytesize}\r\n"
        response += "\r\n"
        response += response_body
      end

    elsif method == 'OPTIONS' && (path == '/book' || path =~ /^\/book\/(.+)$/)
      # CORS preflight
      response = "HTTP/1.1 200 OK\r\n"
      cors_headers.each { |h| response += "#{h}\r\n" }
      response += "\r\n"

    else
      # Not found
      response_body = { error: 'Not found' }.to_json
      response = "HTTP/1.1 404 Not Found\r\n"
      cors_headers.each { |h| response += "#{h}\r\n" }
      response += "Content-Type: application/json\r\n"
      response += "Content-Length: #{response_body.bytesize}\r\n"
      response += "\r\n"
      response += response_body
    end

    client.write(response)
    client.close

  rescue => e
    puts "Error: #{e.message}"
    client.close if client
  end
end