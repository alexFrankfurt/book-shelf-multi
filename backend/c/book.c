#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include <rpc.h>
#else
#include <uuid/uuid.h>
#endif
#include "book.h"

#define MAX_BOOKS 1000

static Book books[MAX_BOOKS];
static int book_count = 0;

void init_book_storage(void) {
    book_count = 0;
    memset(books, 0, sizeof(books));
}

void cleanup_book_storage(void) {
    // Nothing to cleanup for in-memory storage
}

static void generate_uuid(char *uuid_str) {
#ifdef _WIN32
    UUID uuid;
    UuidCreate(&uuid);
    unsigned char *str;
    UuidToStringA(&uuid, &str);
    strncpy(uuid_str, (char*)str, 36);
    uuid_str[36] = '\0';
    RpcStringFreeA(&str);
#else
    uuid_t uuid;
    uuid_generate(uuid);
    uuid_unparse(uuid, uuid_str);
#endif
}

Book* create_book(const char *title, const char *author, const char *description, const char *coverImageUrl) {
    if (book_count >= MAX_BOOKS) {
        return NULL;
    }

    if (title == NULL || author == NULL || strlen(title) == 0 || strlen(author) == 0) {
        return NULL;
    }

    Book *book = &books[book_count];
    generate_uuid(book->id);
    
    strncpy(book->title, title, sizeof(book->title) - 1);
    book->title[sizeof(book->title) - 1] = '\0';
    
    strncpy(book->author, author, sizeof(book->author) - 1);
    book->author[sizeof(book->author) - 1] = '\0';
    
    if (description != NULL) {
        strncpy(book->description, description, sizeof(book->description) - 1);
        book->description[sizeof(book->description) - 1] = '\0';
    } else {
        book->description[0] = '\0';
    }
    
    if (coverImageUrl != NULL) {
        strncpy(book->coverImageUrl, coverImageUrl, sizeof(book->coverImageUrl) - 1);
        book->coverImageUrl[sizeof(book->coverImageUrl) - 1] = '\0';
    } else {
        book->coverImageUrl[0] = '\0';
    }

    book_count++;
    return book;
}

Book** get_all_books(int *count) {
    *count = book_count;
    Book **result = malloc(book_count * sizeof(Book*));
    for (int i = 0; i < book_count; i++) {
        result[i] = &books[i];
    }
    return result;
}

Book* get_book_by_id(const char *id) {
    for (int i = 0; i < book_count; i++) {
        if (strcmp(books[i].id, id) == 0) {
            return &books[i];
        }
    }
    return NULL;
}

Book* update_book(const char *id, const char *title, const char *author, const char *description, const char *coverImageUrl) {
    Book *book = get_book_by_id(id);
    if (book == NULL) {
        return NULL;
    }

    if (title != NULL && strlen(title) > 0) {
        strncpy(book->title, title, sizeof(book->title) - 1);
        book->title[sizeof(book->title) - 1] = '\0';
    }
    
    if (author != NULL && strlen(author) > 0) {
        strncpy(book->author, author, sizeof(book->author) - 1);
        book->author[sizeof(book->author) - 1] = '\0';
    }
    
    if (description != NULL) {
        strncpy(book->description, description, sizeof(book->description) - 1);
        book->description[sizeof(book->description) - 1] = '\0';
    }
    
    if (coverImageUrl != NULL) {
        strncpy(book->coverImageUrl, coverImageUrl, sizeof(book->coverImageUrl) - 1);
        book->coverImageUrl[sizeof(book->coverImageUrl) - 1] = '\0';
    }

    return book;
}

int delete_book_by_id(const char *id) {
    for (int i = 0; i < book_count; i++) {
        if (strcmp(books[i].id, id) == 0) {
            // Shift all books after this one
            for (int j = i; j < book_count - 1; j++) {
                books[j] = books[j + 1];
            }
            book_count--;
            return 1;
        }
    }
    return 0;
}
