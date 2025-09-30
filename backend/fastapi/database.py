import os
import uuid
from pymongo import MongoClient
import oracledb

db_type = os.getenv("DB_TYPE")

db = {}

def connect_to_db():
    if db_type == "mongodb":
        mongo_uri = os.getenv("MONGO_URI")
        db['client'] = MongoClient(mongo_uri)
        db['collection'] = db['client'].get_database().get_collection("books")
    elif db_type == "oracledb":
        if os.getenv("ORACLE_LIB_DIR"):
            oracledb.init_oracle_client(lib_dir=os.getenv("ORACLE_LIB_DIR"))
        db['connection'] = oracledb.connect(
            user=os.getenv("ORACLE_USER"),
            password=os.getenv("ORACLE_PASSWORD"),
            dsn=os.getenv("ORACLE_CONNECTION_STRING")
        )
        db['connection'].autocommit = True
        ensure_table_exists(db['connection'])
    else:
        db['books'] = []

def ensure_table_exists(connection):
    try:
        cursor = connection.cursor()
        cursor.execute(
            """
            CREATE TABLE books (
                id VARCHAR2(36) PRIMARY KEY,
                title VARCHAR2(255) NOT NULL,
                author VARCHAR2(255) NOT NULL,
                description VARCHAR2(4000),
                cover_image_url VARCHAR2(2048)
            )
            """
        )
    except oracledb.DatabaseError as e:
        if e.args[0].code != 955: # ORA-00955: name is already used by an existing object
            raise
    finally:
        cursor.close()

def create_book(book):
    book_id = str(uuid.uuid4())
    new_book = {**book.dict(), "id": book_id}
    if db_type == "mongodb":
        db['collection'].insert_one(new_book)
    elif db_type == "oracledb":
        cursor = db['connection'].cursor()
        cursor.execute(
            """
            INSERT INTO books (id, title, author, description, cover_image_url)
            VALUES (:id, :title, :author, :description, :cover_image_url)
            """,
            new_book
        )
        cursor.close()
    else:
        db['books'].append(new_book)
    return new_book

def get_all_books():
    if db_type == "mongodb":
        return list(db['collection'].find({}, {'_id': 0}))
    elif db_type == "oracledb":
        cursor = db['connection'].cursor()
        cursor.execute("SELECT * FROM books")
        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]
        cursor.close()
        return [dict(zip(columns, row)) for row in rows]
    else:
        return db['books']

def get_book(book_id):
    if db_type == "mongodb":
        return db['collection'].find_one({"id": book_id}, {'_id': 0})
    elif db_type == "oracledb":
        cursor = db['connection'].cursor()
        cursor.execute("SELECT * FROM books WHERE id = :id", {"id": book_id})
        row = cursor.fetchone()
        if not row:
            return None
        columns = [col[0] for col in cursor.description]
        cursor.close()
        return dict(zip(columns, row))
    else:
        for book in db['books']:
            if book['id'] == book_id:
                return book
        return None

def update_book(book_id, book_update):
    if db_type == "mongodb":
        result = db['collection'].find_one_and_update(
            {"id": book_id},
            {"$set": book_update.dict(exclude_unset=True)},
            return_document=True
        )
        return result
    elif db_type == "oracledb":
        book = get_book(book_id)
        if not book:
            return None
        updated_book = {**book, **book_update.dict(exclude_unset=True)}
        cursor = db['connection'].cursor()
        cursor.execute(
            """
            UPDATE books
            SET title = :title, author = :author, description = :description, cover_image_url = :cover_image_url
            WHERE id = :id
            """,
            updated_book
        )
        cursor.close()
        return updated_book
    else:
        for i, book in enumerate(db['books']):
            if book['id'] == book_id:
                updated_book = {**book, **book_update.dict(exclude_unset=True)}
                db['books'][i] = updated_book
                return updated_book
        return None

def delete_book(book_id):
    if db_type == "mongodb":
        result = db['collection'].delete_one({"id": book_id})
        return result.deleted_count > 0
    elif db_type == "oracledb":
        cursor = db['connection'].cursor()
        cursor.execute("DELETE FROM books WHERE id = :id", {"id": book_id})
        rows_deleted = cursor.rowcount
        cursor.close()
        return rows_deleted > 0
    else:
        initial_len = len(db['books'])
        db['books'] = [b for b in db['books'] if b['id'] != book_id]
        return len(db['books']) < initial_len
