module Main

import Data.String
import Data.Maybe
import Data.IORef as IORef
import Data.ByteString
import Data.List as List
import Network.HTTP.Server
import Network.HTTP.Application
import Data.List1 as List1
import Network.HTTP.Headers
import Network.HTTP.Methods
import Network.HTTP.Request
import Network.HTTP.Response
import Network.Socket
import JSON
import Network.HTTP.Connection

-- Book record
record Book where
  constructor MkBook
  id : Int
  title : String
  author : String
  description : String
  coverImageUrl : String

record BookPayload where
  constructor MkBookPayload
  title : String
  author : String
  description : String
  coverImageUrl : String

implementation FromJSON BookPayload where
  fromJSON = withObject "BookPayload" $ \obj => do
    title <- field obj "title"
    author <- field obj "author"
    description <- field obj "description"
    coverImageUrl <- field obj "coverImageUrl"
    pure (MkBookPayload title author description coverImageUrl)

-- JSON instances for Book
implementation ToJSON Book where
  toJSON (MkBook id title author description coverImageUrl) =
    object [ ("id", toJSON id)
           , ("title", toJSON title)
           , ("author", toJSON author)
           , ("description", toJSON description)
           , ("coverImageUrl", toJSON coverImageUrl)
           ]

implementation FromJSON Book where
  fromJSON = withObject "Book" $ \obj => do
    id <- field obj "id"
    title <- field obj "title"
    author <- field obj "author"
    description <- field obj "description"
    coverImageUrl <- field obj "coverImageUrl"
    pure (MkBook id title author description coverImageUrl)

initialBooks : List Book
initialBooks =
  [ MkBook 1 "The Lord of the Rings" "J.R.R. Tolkien" "A classic fantasy novel." "http://example.com/cover.jpg"
  ]

serverPort : Port
serverPort = fromInteger 3000


-- Helper to create a JSON response
jsonResponse : ToJSON a => Status -> a -> Response ByteString
jsonResponse status body =
  let
    payload : String = encode body
    headers = addHeader (MkHeader "Content-Type" ["application/json"]) empty
  in MkResponse status headers (cast {to = ByteString} payload)

-- Helper to create a text response
textResponse : Status -> String -> Response ByteString
textResponse status body =
  let headers = addHeader (MkHeader "Content-Type" ["text/plain"]) empty
  in MkResponse status headers (cast {to = ByteString} body)

getBooks : IORef.IORef (List Book) -> Application
getBooks booksRef req responder = do
  allBooks <- IORef.readIORef booksRef
  responder $ jsonResponse statusOK allBooks

-- Get book by id
getBook : IORef.IORef (List Book) -> Int -> Application
getBook booksRef id req responder = do
  allBooks <- IORef.readIORef booksRef
  case List.find (\b => b.id == id) allBooks of
    Just book => responder $ jsonResponse statusOK book
    Nothing => responder $ textResponse statusNotFound "Book not found"

-- Create a new book
createBook : IORef.IORef (List Book) -> Application
createBook booksRef req responder = do
  bodyResult <- readRequestBody req
  case bodyResult of
    Left _ => responder $ textResponse statusBadRequest "Invalid request body"
    Right body =>
      case decodeEither {a = BookPayload} (Data.ByteString.toString body) of
        Left _ => responder $ textResponse statusBadRequest "Invalid book data"
        Right (MkBookPayload title author description coverImageUrl) => do
          allBooks <- IORef.readIORef booksRef
          let nextId = foldl (\acc, b => max acc b.id) 0 allBooks + 1
          let finalBook = MkBook nextId title author description coverImageUrl
          IORef.writeIORef booksRef (finalBook :: allBooks)
          responder $ jsonResponse statusCreated finalBook

-- Update a book
updateBook : IORef.IORef (List Book) -> Int -> Application
updateBook booksRef id req responder = do
  bodyResult <- readRequestBody req
  case bodyResult of
    Left _ => responder $ textResponse statusBadRequest "Invalid request body"
    Right body =>
      case decodeEither {a = BookPayload} (Data.ByteString.toString body) of
        Left _ => responder $ textResponse statusBadRequest "Invalid book data"
        Right (MkBookPayload title author description coverImageUrl) => do
          allBooks <- IORef.readIORef booksRef
          if any (\b => b.id == id) allBooks
            then do
              let updatedBook = MkBook id title author description coverImageUrl
              let newBooks = map (\b => if b.id == id then updatedBook else b) allBooks
              IORef.writeIORef booksRef newBooks
              responder $ jsonResponse statusOK updatedBook
            else responder $ textResponse statusNotFound "Book not found"

-- Delete a book
deleteBook : IORef.IORef (List Book) -> Int -> Application
deleteBook booksRef id req responder = do
  allBooks <- IORef.readIORef booksRef
  if any (\b => b.id == id) allBooks
    then do
      let newBooks = filter (\b => b.id /= id) allBooks
      IORef.writeIORef booksRef newBooks
      responder $ textResponse statusOK "Book deleted"
    else responder $ textResponse statusNotFound "Book not found"

-- Router
app : IORef.IORef (List Book) -> Application
app booksRef req responder =
  let
    method = req.method
    segments = List1.forget (split (=='/') req.resource)
  in case (req.resource, segments, method) of
        ("/books", _, GET) => getBooks booksRef req responder
        ("/books", _, POST) => createBook booksRef req responder
        ("/books", _, _) => responder $ textResponse statusMethodNotAllowed "Method not allowed"
        (_, ["", "books", idStr], meth) =>
          case parseInteger idStr of
            Nothing => responder $ textResponse statusBadRequest "Invalid book ID"
            Just rawId =>
              let bookId : Int = fromInteger rawId
               in case meth of
                    GET => getBook booksRef bookId req responder
                    PUT => updateBook booksRef bookId req responder
                    DELETE => deleteBook booksRef bookId req responder
                    _ => responder $ textResponse statusMethodNotAllowed "Method not allowed"
        _ => responder $ textResponse statusNotFound "Not Found"

-- Main entry point
main : IO ()
main = do
  putStrLn "Starting server on port 3000"
  booksRef <- IORef.newIORef initialBooks
  res <- listenAndServe serverPort (app booksRef)
  print res
