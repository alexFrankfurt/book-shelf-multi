#include <crow.h>
#include "crow/middlewares/cors.h"
#include <nlohmann/json.hpp>
#include <vector>
#include <string>
#include <mutex>
#include <optional> // For std::optional
#include <atomic>   // For std::atomic in generate_uuid

// Simple Book structure
struct Book {
    std::optional<std::string> id;
    std::string title;
    std::string author;
    std::optional<std::string> published_date;
    std::string coverImageUrl;

    // Helper to convert Book to Crow JSON
    crow::json::wvalue to_json() const {
        crow::json::wvalue x({});
        if (id) {
            x["id"] = *id;
        }
        x["title"] = title;
        x["author"] = author;
        if (published_date) {
            x["published_date"] = *published_date;
        }
        x["coverImageUrl"] = coverImageUrl;
        return x;
    }
};

// In-memory storage for books
std::vector<Book> books;
std::mutex books_mutex; // To protect access to the books vector

// Function to generate a UUID (simplified for this example)
std::string generate_uuid() {
    static std::atomic<long long> counter(0);
    return "cpp-" + std::to_string(counter++);
}

int main() {
    crow::App<crow::CORSHandler> app;

    // Configure CORS
    auto& cors = app.get_middleware<crow::CORSHandler>();
    cors.global()
        .origin("*")
        .methods("POST"_method, "GET"_method, "PUT"_method, "DELETE"_method, "OPTIONS"_method)
        .headers("Content-Type", "Authorization", "X-Requested-With");

    // GET all books
    CROW_ROUTE(app, "/book")
        .methods("GET"_method)([&]() {
            std::lock_guard<std::mutex> lock(books_mutex);
            crow::json::wvalue x;
            for (size_t i = 0; i < books.size(); ++i) {
                x[i] = books[i].to_json();
            }
            return crow::response(200, x.dump());
        });

    // GET a single book by ID
    CROW_ROUTE(app, "/book/<string>")
        .methods("GET"_method)([&](const std::string& id) {
            std::lock_guard<std::mutex> lock(books_mutex);
            for (const auto& book : books) {
                if (book.id && *book.id == id) {
                    return crow::response(200, book.to_json().dump());
                }
            }
            return crow::response(404, "Book not found");
        });

    // POST create a new book
    CROW_ROUTE(app, "/book")
        .methods("POST"_method)([&](const crow::request& req) {
            std::lock_guard<std::mutex> lock(books_mutex);
            auto json_body = crow::json::load(req.body);
            if (!json_body) {
                return crow::response(400, "Invalid JSON");
            }

            Book new_book;
            new_book.id = generate_uuid();
            new_book.title = json_body["title"].s();
            new_book.author = json_body["author"].s();
            
            // Handle optional published_date
            if (json_body.has("published_date") && json_body["published_date"].t() != crow::json::type::Null) {
                new_book.published_date = json_body["published_date"].s();
            } else {
                new_book.published_date = std::nullopt; // Explicitly set to nullopt if not provided
            }

            new_book.coverImageUrl = json_body["coverImageUrl"].s();

            books.push_back(new_book);
            return crow::response(201, new_book.to_json().dump());
        });

    // PUT update a book
    CROW_ROUTE(app, "/book/<string>")
        .methods("PUT"_method)([&](const crow::request& req, const std::string& id) {
            std::lock_guard<std::mutex> lock(books_mutex);
            auto json_body = crow::json::load(req.body);
            if (!json_body) {
                return crow::response(400, "Invalid JSON");
            }

            for (auto& book : books) {
                if (book.id && *book.id == id) {
                    book.title = json_body["title"].s();
                    book.author = json_body["author"].s();
                    
                    // Handle optional published_date
                    if (json_body.has("published_date") && json_body["published_date"].t() != crow::json::type::Null) {
                        book.published_date = json_body["published_date"].s();
                    } else {
                        book.published_date = std::nullopt;
                    }

                    book.coverImageUrl = json_body["coverImageUrl"].s();
                    return crow::response(200, book.to_json().dump());
                }
            }
            return crow::response(404, "Book not found");
        });

    // DELETE a book
    CROW_ROUTE(app, "/book/<string>")
        .methods("DELETE"_method)([&](const std::string& id) {
            std::lock_guard<std::mutex> lock(books_mutex);
            auto it = std::remove_if(books.begin(), books.end(), [&](const Book& book) {
                return book.id && *book.id == id;
            });

            if (it != books.end()) {
                books.erase(it, books.end());
                return crow::response(204);
            }
            return crow::response(404, "Book not found");
        });

    // Add an initial book
    { // Use a block to ensure lock_guard is released
        std::lock_guard<std::mutex> lock(books_mutex);
        books.push_back({
            generate_uuid(),
            "The C++ Programming Language",
            "Bjarne Stroustrup",
            "1985-10-14",
            "https://covers.openlibrary.org/b/id/6660100-L.jpg"
        });
    }

    app.port(8080).multithreaded().run();
}
 