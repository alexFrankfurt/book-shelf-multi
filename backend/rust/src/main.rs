use actix_web::{get, post, put, delete, web, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use actix_cors::Cors;

#[derive(Serialize, Deserialize, Clone)]
struct Book {
    id: Option<String>,
    title: String,
    author: String,
    #[serde(default)]
    published_date: Option<String>,
    coverImageUrl: String,
}

struct AppState {
    books: Mutex<Vec<Book>>,
}

#[get("/book")]
async fn get_books(data: web::Data<AppState>) -> impl Responder {
    let books = data.books.lock().unwrap();
    HttpResponse::Ok().json(books.clone())
}

#[get("/book/{id}")]
async fn get_book(data: web::Data<AppState>, id: web::Path<String>) -> impl Responder {
    let books = data.books.lock().unwrap();
    let book_id = id.into_inner();
    if let Some(book) = books.iter().find(|b| b.id.as_ref().map_or(false, |id_str| id_str == &book_id)) {
        HttpResponse::Ok().json(book)
    } else {
        HttpResponse::NotFound().body("Book not found")
    }
}

#[post("/book")]
async fn create_book(data: web::Data<AppState>, book: web::Json<Book>) -> impl Responder {
    let mut books = data.books.lock().unwrap();
    let mut new_book = book.into_inner();
    let generated_id = uuid::Uuid::new_v4().to_string();
    new_book.id = Some(generated_id.clone());
    books.push(new_book.clone());
    HttpResponse::Created().json(new_book)
}

#[put("/book/{id}")]
async fn update_book(data: web::Data<AppState>, id: web::Path<String>, updated_book: web::Json<Book>) -> impl Responder {
    let mut books = data.books.lock().unwrap();
    let book_id = id.into_inner();
    if let Some(book) = books.iter_mut().find(|b| b.id.as_ref().map_or(false, |id_str| id_str == &book_id)) {
        *book = updated_book.into_inner();
        book.id = Some(book_id.clone());
        HttpResponse::Ok().json(book.clone())
    } else {
        HttpResponse::NotFound().body("Book not found")
    }
}

#[delete("/book/{id}")]
async fn delete_book(data: web::Data<AppState>, id: web::Path<String>) -> impl Responder {
    let mut books = data.books.lock().unwrap();
    let book_id = id.into_inner();
    if let Some(pos) = books.iter().position(|b| b.id.as_ref().map_or(false, |id_str| id_str == &book_id)) {
        books.remove(pos);
        HttpResponse::NoContent().finish()
    } else {
        HttpResponse::NotFound().body("Book not found")
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let app_state = web::Data::new(AppState {
        books: Mutex::new(vec![
            Book {
                id: Some("1".to_string()),
                title: "The Lord of the Rings".to_string(),
                author: "J.R.R. Tolkien".to_string(),
                published_date: Some("1954-07-29".to_string()),
                coverImageUrl: "https://covers.openlibrary.org/b/id/6660100-L.jpg".to_string(),
            }
        ]),
    });

    HttpServer::new(move || {
        let cors = Cors::default()
            .allowed_origin("http://localhost:3000")
            .allow_any_method()
            .allow_any_header()
            .max_age(3600);

        App::new()
            .app_data(app_state.clone())
            .wrap(cors)
            .service(get_books)
            .service(get_book)
            .service(create_book)
            .service(update_book)
            .service(delete_book)
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}