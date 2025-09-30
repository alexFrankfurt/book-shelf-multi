#ifndef BOOK_H
#define BOOK_H

typedef struct {
    char id[37];  // UUID
    char title[256];
    char author[256];
    char description[1024];
    char coverImageUrl[512];
} Book;

// Initialize storage
void init_book_storage(void);

// Cleanup storage
void cleanup_book_storage(void);

// CRUD operations
Book* create_book(const char *title, const char *author, const char *description, const char *coverImageUrl);
Book** get_all_books(int *count);
Book* get_book_by_id(const char *id);
Book* update_book(const char *id, const char *title, const char *author, const char *description, const char *coverImageUrl);
int delete_book_by_id(const char *id);

#endif
