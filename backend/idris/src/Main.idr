module Main

import Data.String
import Data.Vect
import Data.Maybe
import System.Info
import Network.HTTP.Server
import Network.HTTP.Application
import Network.HTTP.Headers
import Network.HTTP.Request
import Network.HTTP.Response
import Network.Socket
import Data.IORef
import Data.ByteString
import Data.Bits
import JSON

-- Book record
record Book where
  constructor MkBook
  id : Int
  title : String
  author : String
  description : String
  coverImageUrl : String

-- JSON instances for Book
implementation ToJSON Book where
  toJSON (MkBook id title author description coverImageUrl) =
    JObject [ ("id", JNumber (cast id))
            , ("title", JString title)
            , ("author", JString author)
            , ("description", JString description)
            , ("coverImageUrl", JString coverImageUrl)
            ]

implementation FromJSON Book where
  fromJSON (JObject obj) = do
    id <- lookup "id" obj >>= fromJSON
    title <- lookup "title" obj >>= fromJSON
    author <- lookup "author" obj >>= fromJSON
    description <- lookup "description" obj >>= fromJSON
    coverImageUrl <- lookup "coverImageUrl" obj >>= fromJSON
    pure (MkBook id title author description coverImageUrl)
  fromJSON _ = Nothing

-- In-memory book store
books : IORef (Vect Book)
books = unsafePerformIO (newIORef [MkBook 1 "The Lord of the Rings" "J.R.R. Tolkien" "A classic fantasy novel." "http://example.com/cover.jpg"])

-- Helper to create a JSON response
jsonResponse : ToJSON a => Status -> a -> Response ByteString
jsonResponse status body = MkResponse status [("Content-Type", "application/json")] (pack (toString (toJSON body)))

-- Helper to create a text response
textResponse : Status -> String -> Response ByteString
textResponse status body = MkResponse status [("Content-Type", "text/plain")] (pack body)

-- Get all books
getBooks : Application
getBooks req responder = do
  allBooks <- readIORef books
  responder $ jsonResponse statusOK allBooks

-- Get book by id
getBook : Int -> Application
getBook id req responder = do
  allBooks <- readIORef books
  case find (\b => b.id == id) allBooks of
    Just book => responder $ jsonResponse statusOK book
    Nothing => responder $ textResponse statusNotFound "Book not found"

-- Create a new book
createBook : Application
createBook req responder = do
  Right body <- readRequestBody req
    | Left err => responder $ textResponse statusBadRequest "Invalid request body"
  case fromString (toString body) of
    Just (JObject obj) => do
      let maybeBook = do
            title <- lookup "title" obj >>= fromJSON
            author <- lookup "author" obj >>= fromJSON
            description <- lookup "description" obj >>= fromJSON
            coverImageUrl <- lookup "coverImageUrl" obj >>= fromJSON
            pure (MkBook 0 title author description coverImageUrl)
      case maybeBook of
        Just newBook => do
          allBooks <- readIORef books
          let newId = case maximum (map (\b => b.id) allBooks) of
                        Nothing => 1
                        Just maxId => maxId + 1
          let finalBook = MkBook newId newBook.title newBook.author newBook.description newBook.coverImageUrl
          writeIORef books (finalBook :: allBooks)
          responder $ jsonResponse statusCreated finalBook
        Nothing => responder $ textResponse statusBadRequest "Invalid book data"
    _ => responder $ textResponse statusBadRequest "Invalid JSON"

-- Update a book
updateBook : Int -> Application
updateBook id req responder = do
  Right body <- readRequestBody req
    | Left err => responder $ textResponse statusBadRequest "Invalid request body"
  case fromString (toString body) of
    Just (JObject obj) => do
      let maybeBook = do
            title <- lookup "title" obj >>= fromJSON
            author <- lookup "author" obj >>= fromJSON
            description <- lookup "description" obj >>= fromJSON
            coverImageUrl <- lookup "coverImageUrl" obj >>= fromJSON
            pure (MkBook id title author description coverImageUrl)
      case maybeBook of
        Just updatedBook => do
          allBooks <- readIORef books
          if any (\b => b.id == id) allBooks
            then do
              let newBooks = map (\b => if b.id == id then updatedBook else b) allBooks
              writeIORef books newBooks
              responder $ jsonResponse statusOK updatedBook
            else responder $ textResponse statusNotFound "Book not found"
        Nothing => responder $ textResponse statusBadRequest "Invalid book data"
    _ => responder $ textResponse statusBadRequest "Invalid JSON"

-- Delete a book
deleteBook : Int -> Application
deleteBook id req responder = do
  allBooks <- readIORef books
  if any (\b => b.id == id) allBooks
    then do
      let newBooks = filter (\b => b.id /= id) allBooks
      writeIORef books newBooks
      responder $ textResponse statusOK "Book deleted"
    else responder $ textResponse statusNotFound "Book not found"

-- Router
app : Application
app req responder =
  case req.resource of
    "/books" =>
      case req.method of
        GET => getBooks req responder
        POST => createBook req responder
        _ => responder $ textResponse statusMethodNotAllowed "Method not allowed"
    _ =>
      case (req.method, split (=='/') req.resource) of
        (GET, ["", "books", idStr]) =>
          case parseInteger idStr of
            Just id => getBook id req responder
            Nothing => responder $ textResponse statusBadRequest "Invalid book ID"
        (PUT, ["", "books", idStr]) =>
          case parseInteger idStr of
            Just id => updateBook id req responder
            Nothing => responder $ textResponse statusBadRequest "Invalid book ID"
        (DELETE, ["", "books", idStr]) =>
          case parseInteger idStr of
            Just id => deleteBook id req responder
            Nothing => responder $ textResponse statusBadRequest "Invalid book ID"
        _ => responder $ textResponse statusNotFound "Not Found"

-- Main entry point
main : IO ()
main = do
  putStrLn "Starting server on port 8008"
  res <- listenAndServe (MkPort 8008 TCP) app
  print res
