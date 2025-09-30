{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Web.Scotty
import Data.Aeson (FromJSON, ToJSON, encode, decode)
import Data.Text (Text, pack, unpack)
import Data.UUID (UUID, toString, fromString)
import Data.UUID.V4 (nextRandom)
import qualified Data.HashMap.Strict as HM
import Control.Concurrent.STM (TVar, newTVarIO, readTVarIO, atomically, modifyTVar')
import Control.Monad.IO.Class (liftIO)
import Network.HTTP.Types (status200, status404, status400, status201, status204)
import GHC.Generics

-- Book data type
data Book = Book
  { bookId :: Maybe Text
  , title :: Text
  , author :: Text
  , description :: Maybe Text
  , coverImageUrl :: Maybe Text
  } deriving (Show, Generic)

instance FromJSON Book
instance ToJSON Book

-- In-memory storage
type BookStore = HM.HashMap Text Book

-- Application state
data AppState = AppState
  { books :: TVar BookStore
  }

-- Create a new book with generated UUID
createBook :: Book -> IO Book
createBook book = do
  uuid <- nextRandom
  let bookId = pack $ toString uuid
  return book { bookId = Just bookId }

-- Main application
main :: IO ()
main = do
  -- Initialize empty book store
  bookStore <- newTVarIO HM.empty
  let appState = AppState bookStore

  scotty 3000 $ do
    -- Routes
    -- OPTIONS handlers for CORS preflight requests
    options "/book" $ do
      setHeader "Access-Control-Allow-Origin" "*"
      setHeader "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
      setHeader "Access-Control-Allow-Headers" "Content-Type"
      status status200

    options "/book/:id" $ do
      setHeader "Access-Control-Allow-Origin" "*"
      setHeader "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
      setHeader "Access-Control-Allow-Headers" "Content-Type"
      status status200

    get "/book" $ do
      setHeader "Access-Control-Allow-Origin" "*"
      setHeader "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
      setHeader "Access-Control-Allow-Headers" "Content-Type"
      bookMap <- liftIO $ readTVarIO (books appState)
      json $ HM.elems bookMap

    get "/book/:id" $ do
      setHeader "Access-Control-Allow-Origin" "*"
      setHeader "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
      setHeader "Access-Control-Allow-Headers" "Content-Type"
      bookId <- param "id"
      bookMap <- liftIO $ readTVarIO (books appState)
      case HM.lookup (pack bookId) bookMap of
        Just book -> json book
        Nothing -> status status404

    post "/book" $ do
      setHeader "Access-Control-Allow-Origin" "*"
      setHeader "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
      setHeader "Access-Control-Allow-Headers" "Content-Type"
      bookData <- jsonData :: ActionM Book
      newBook <- liftIO $ createBook bookData
      liftIO $ atomically $ modifyTVar' (books appState) $ HM.insert (maybe "" id (bookId newBook)) newBook
      status status201
      json newBook

    put "/book/:id" $ do
      setHeader "Access-Control-Allow-Origin" "*"
      setHeader "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
      setHeader "Access-Control-Allow-Headers" "Content-Type"
      bookId <- param "id"
      updateData <- jsonData :: ActionM Book
      bookMap <- liftIO $ readTVarIO (books appState)
      case HM.lookup (pack bookId) bookMap of
        Just existingBook -> do
          let updatedBook = existingBook
                { title = title updateData
                , author = author updateData
                , description = description updateData
                , coverImageUrl = coverImageUrl updateData
                }
          liftIO $ atomically $ modifyTVar' (books appState) $ HM.insert (pack bookId) updatedBook
          json updatedBook
        Nothing -> status status404

    delete "/book/:id" $ do
      setHeader "Access-Control-Allow-Origin" "*"
      setHeader "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS"
      setHeader "Access-Control-Allow-Headers" "Content-Type"
      bookId <- param "id"
      liftIO $ atomically $ modifyTVar' (books appState) $ HM.delete (pack bookId)
      status status204