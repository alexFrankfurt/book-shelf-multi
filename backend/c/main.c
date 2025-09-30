#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <microhttpd.h>
#include "book.h"
#include "json.h"

#define PORT 3000
#define POSTBUFFERSIZE 4096

struct connection_info {
    char *data;
    size_t size;
};

static enum MHD_Result
answer_to_connection(void *cls, struct MHD_Connection *connection,
                      const char *url, const char *method,
                      const char *version, const char *upload_data,
                      size_t *upload_data_size, void **con_cls)
{
    struct MHD_Response *response;
    enum MHD_Result ret;
    char *response_text = NULL;
    int status_code = MHD_HTTP_OK;

    // Handle CORS preflight
    if (strcmp(method, "OPTIONS") == 0) {
        response = MHD_create_response_from_buffer(0, "", MHD_RESPMEM_PERSISTENT);
        MHD_add_response_header(response, "Access-Control-Allow-Origin", "*");
        MHD_add_response_header(response, "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        MHD_add_response_header(response, "Access-Control-Allow-Headers", "Content-Type");
        ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
        MHD_destroy_response(response);
        return ret;
    }

    // Initialize connection info on first call
    if (*con_cls == NULL) {
        if (strcmp(method, "POST") == 0 || strcmp(method, "PUT") == 0) {
            struct connection_info *con_info = malloc(sizeof(struct connection_info));
            con_info->data = NULL;
            con_info->size = 0;
            *con_cls = con_info;
            return MHD_YES;
        }
        *con_cls = (void *)1; // Mark as initialized for GET/DELETE
    }

    // Handle POST/PUT data accumulation
    if (*upload_data_size != 0) {
        struct connection_info *con_info = *con_cls;
        if (con_info->data == NULL) {
            con_info->data = malloc(*upload_data_size + 1);
            memcpy(con_info->data, upload_data, *upload_data_size);
            con_info->data[*upload_data_size] = '\0';
            con_info->size = *upload_data_size;
        } else {
            con_info->data = realloc(con_info->data, con_info->size + *upload_data_size + 1);
            memcpy(con_info->data + con_info->size, upload_data, *upload_data_size);
            con_info->size += *upload_data_size;
            con_info->data[con_info->size] = '\0';
        }
        *upload_data_size = 0;
        return MHD_YES;
    }

    // GET /book - Get all books
    if (strcmp(method, "GET") == 0 && strcmp(url, "/book") == 0) {
        response_text = get_all_books_json();
        status_code = MHD_HTTP_OK;
    }
    // GET /book/:id - Get a specific book
    else if (strcmp(method, "GET") == 0 && strncmp(url, "/book/", 6) == 0) {
        const char *id = url + 6;
        response_text = get_book_by_id_json(id);
        if (response_text == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), "{\"error\":\"Book with ID %s not found\"}", id);
            response_text = strdup(error_msg);
            status_code = MHD_HTTP_NOT_FOUND;
        }
    }
    // POST /book - Create a book
    else if (strcmp(method, "POST") == 0 && strcmp(url, "/book") == 0) {
        struct connection_info *con_info = *con_cls;
        if (con_info != NULL && con_info->data != NULL) {
            response_text = create_book_json(con_info->data);
            if (response_text == NULL) {
                response_text = strdup("{\"error\":\"Title and author are required\"}");
                status_code = MHD_HTTP_BAD_REQUEST;
            } else {
                status_code = MHD_HTTP_CREATED;
            }
        } else {
            response_text = strdup("{\"error\":\"No data provided\"}");
            status_code = MHD_HTTP_BAD_REQUEST;
        }
    }
    // PUT /book/:id - Update a book
    else if (strcmp(method, "PUT") == 0 && strncmp(url, "/book/", 6) == 0) {
        const char *id = url + 6;
        struct connection_info *con_info = *con_cls;
        if (con_info != NULL && con_info->data != NULL) {
            response_text = update_book_json(id, con_info->data);
            if (response_text == NULL) {
                char error_msg[256];
                snprintf(error_msg, sizeof(error_msg), "{\"error\":\"Book with ID %s not found\"}", id);
                response_text = strdup(error_msg);
                status_code = MHD_HTTP_NOT_FOUND;
            }
        } else {
            response_text = strdup("{\"error\":\"No data provided\"}");
            status_code = MHD_HTTP_BAD_REQUEST;
        }
    }
    // DELETE /book/:id - Delete a book
    else if (strcmp(method, "DELETE") == 0 && strncmp(url, "/book/", 6) == 0) {
        const char *id = url + 6;
        int deleted = delete_book_by_id(id);
        if (deleted) {
            response = MHD_create_response_from_buffer(0, "", MHD_RESPMEM_PERSISTENT);
            MHD_add_response_header(response, "Access-Control-Allow-Origin", "*");
            MHD_add_response_header(response, "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
            MHD_add_response_header(response, "Access-Control-Allow-Headers", "Content-Type");
            ret = MHD_queue_response(connection, MHD_HTTP_NO_CONTENT, response);
            MHD_destroy_response(response);
            return ret;
        } else {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), "{\"error\":\"Book with ID %s not found\"}", id);
            response_text = strdup(error_msg);
            status_code = MHD_HTTP_NOT_FOUND;
        }
    }
    // 404 for unmatched routes
    else {
        response_text = strdup("{\"error\":\"Route not found\"}");
        status_code = MHD_HTTP_NOT_FOUND;
    }

    // Create and send response
    if (response_text == NULL) {
        response_text = strdup("{\"error\":\"Internal server error\"}");
        status_code = MHD_HTTP_INTERNAL_SERVER_ERROR;
    }

    response = MHD_create_response_from_buffer(strlen(response_text),
                                               (void *)response_text,
                                               MHD_RESPMEM_MUST_FREE);
    MHD_add_response_header(response, "Content-Type", "application/json");
    MHD_add_response_header(response, "Access-Control-Allow-Origin", "*");
    MHD_add_response_header(response, "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
    MHD_add_response_header(response, "Access-Control-Allow-Headers", "Content-Type");
    
    ret = MHD_queue_response(connection, status_code, response);
    MHD_destroy_response(response);

    // Cleanup connection info
    if (*con_cls != NULL && *con_cls != (void *)1) {
        struct connection_info *con_info = *con_cls;
        if (con_info->data != NULL) {
            free(con_info->data);
        }
        free(con_info);
        *con_cls = NULL;
    }

    return ret;
}

int main(void)
{
    struct MHD_Daemon *daemon;

    init_book_storage();

    daemon = MHD_start_daemon(MHD_USE_INTERNAL_POLLING_THREAD, PORT, NULL, NULL,
                               &answer_to_connection, NULL, MHD_OPTION_END);
    if (NULL == daemon) {
        fprintf(stderr, "Failed to start server\n");
        return 1;
    }

    printf("Plain C API listening at http://localhost:%d\n", PORT);
    printf("Press Enter to stop the server...\n");
    getchar();

    MHD_stop_daemon(daemon);
    cleanup_book_storage();

    return 0;
}
