from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from database import (
    connect_to_db,
    create_book as db_create_book,
    get_all_books as db_get_all_books,
    get_book as db_get_book,
    update_book as db_update_book,
    delete_book as db_delete_book,
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class BookBase(BaseModel):
    title: str
    author: str
    description: Optional[str] = ""
    cover_image_url: Optional[str] = ""

class BookCreate(BookBase):
    pass

class BookUpdate(BaseModel):
    title: Optional[str] = None
    author: Optional[str] = None
    description: Optional[str] = None
    cover_image_url: Optional[str] = None

class Book(BookBase):
    id: str

@app.on_event("startup")
def startup_event():
    connect_to_db()

@app.post("/book", response_model=Book, status_code=status.HTTP_201_CREATED)
async def create_book(book: BookCreate):
    new_book = db_create_book(book)
    return new_book

@app.get("/book", response_model=List[Book])
async def get_all_books():
    return db_get_all_books()

@app.get("/book/{book_id}", response_model=Book)
async def get_book(book_id: str):
    book = db_get_book(book_id)
    if not book:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Book with ID {book_id} not found"
        )
    return book

@app.put("/book/{book_id}", response_model=Book)
async def update_book(book_id: str, book_update: BookUpdate):
    updated_book = db_update_book(book_id, book_update)
    if not updated_book:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Book with ID {book_id} not found"
        )
    return updated_book

@app.delete("/book/{book_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_book(book_id: str):
    deleted = db_delete_book(book_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Book with ID {book_id} not found"
        )