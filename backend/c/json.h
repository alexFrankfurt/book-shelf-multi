#ifndef JSON_H
#define JSON_H

#include "book.h"

// JSON serialization and deserialization
char* get_all_books_json(void);
char* get_book_by_id_json(const char *id);
char* create_book_json(const char *json_data);
char* update_book_json(const char *id, const char *json_data);

#endif
