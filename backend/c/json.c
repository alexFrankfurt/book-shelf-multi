#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <json-c/json.h>
#include "json.h"
#include "book.h"

static char* book_to_json_string(Book *book) {
    struct json_object *jobj = json_object_new_object();
    json_object_object_add(jobj, "id", json_object_new_string(book->id));
    json_object_object_add(jobj, "title", json_object_new_string(book->title));
    json_object_object_add(jobj, "author", json_object_new_string(book->author));
    json_object_object_add(jobj, "description", json_object_new_string(book->description));
    json_object_object_add(jobj, "coverImageUrl", json_object_new_string(book->coverImageUrl));
    
    const char *json_str = json_object_to_json_string(jobj);
    char *result = strdup(json_str);
    json_object_put(jobj);
    return result;
}

char* get_all_books_json(void) {
    int count;
    Book **book_list = get_all_books(&count);
    
    struct json_object *jarray = json_object_new_array();
    for (int i = 0; i < count; i++) {
        struct json_object *jobj = json_object_new_object();
        json_object_object_add(jobj, "id", json_object_new_string(book_list[i]->id));
        json_object_object_add(jobj, "title", json_object_new_string(book_list[i]->title));
        json_object_object_add(jobj, "author", json_object_new_string(book_list[i]->author));
        json_object_object_add(jobj, "description", json_object_new_string(book_list[i]->description));
        json_object_object_add(jobj, "coverImageUrl", json_object_new_string(book_list[i]->coverImageUrl));
        json_object_array_add(jarray, jobj);
    }
    
    const char *json_str = json_object_to_json_string(jarray);
    char *result = strdup(json_str);
    json_object_put(jarray);
    free(book_list);
    return result;
}

char* get_book_by_id_json(const char *id) {
    Book *book = get_book_by_id(id);
    if (book == NULL) {
        return NULL;
    }
    return book_to_json_string(book);
}

static char* get_json_string_field(struct json_object *jobj, const char *key) {
    struct json_object *field;
    if (json_object_object_get_ex(jobj, key, &field)) {
        const char *value = json_object_get_string(field);
        return (value != NULL && strlen(value) > 0) ? strdup(value) : NULL;
    }
    return NULL;
}

char* create_book_json(const char *json_data) {
    struct json_object *jobj = json_tokener_parse(json_data);
    if (jobj == NULL) {
        return NULL;
    }

    char *title = get_json_string_field(jobj, "title");
    char *author = get_json_string_field(jobj, "author");
    char *description = get_json_string_field(jobj, "description");
    char *coverImageUrl = get_json_string_field(jobj, "coverImageUrl");

    Book *new_book = create_book(title, author, description, coverImageUrl);
    
    free(title);
    free(author);
    free(description);
    free(coverImageUrl);
    json_object_put(jobj);

    if (new_book == NULL) {
        return NULL;
    }

    return book_to_json_string(new_book);
}

char* update_book_json(const char *id, const char *json_data) {
    struct json_object *jobj = json_tokener_parse(json_data);
    if (jobj == NULL) {
        return NULL;
    }

    char *title = get_json_string_field(jobj, "title");
    char *author = get_json_string_field(jobj, "author");
    char *description = get_json_string_field(jobj, "description");
    char *coverImageUrl = get_json_string_field(jobj, "coverImageUrl");

    Book *updated_book = update_book(id, title, author, description, coverImageUrl);
    
    free(title);
    free(author);
    free(description);
    free(coverImageUrl);
    json_object_put(jobj);

    if (updated_book == NULL) {
        return NULL;
    }

    return book_to_json_string(updated_book);
}
