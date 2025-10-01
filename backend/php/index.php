<?php

// File-based storage for books
$booksFile = __DIR__ . '/books.json';

// Load books from file
function loadBooks() {
    global $booksFile;
    if (file_exists($booksFile)) {
        $data = json_decode(file_get_contents($booksFile), true);
        return $data ?: [];
    }
    return [];
}

// Save books to file
function saveBooks($books) {
    global $booksFile;
    file_put_contents($booksFile, json_encode($books));
}

// Initialize books
$books = loadBooks();

// Book class
class Book {
    public $bookId;
    public $title;
    public $author;
    public $description;
    public $coverImageUrl;

    public function __construct($title, $author, $description = null, $coverImageUrl = null, $bookId = null) {
        $this->bookId = $bookId ?: $this->generateUUID();
        $this->title = $title;
        $this->author = $author;
        $this->description = $description;
        $this->coverImageUrl = $coverImageUrl;
    }

    private function generateUUID() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }

    public function toArray() {
        return [
            'bookId' => $this->bookId,
            'title' => $this->title,
            'author' => $this->author,
            'description' => $this->description,
            'coverImageUrl' => $this->coverImageUrl
        ];
    }
}

// CORS headers
function sendCorsHeaders() {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
}

// Handle requests
function handleRequest($method, $path, $input) {
    global $books;

    // CORS preflight
    if ($method === 'OPTIONS') {
        sendCorsHeaders();
        return ['status' => 200];
    }

    // Parse path
    $pathParts = explode('/', trim($path, '/'));
    $endpoint = $pathParts[0] ?? '';
    $id = $pathParts[1] ?? null;

    switch ($method) {
        case 'GET':
            if ($endpoint === 'book') {
                if ($id) {
                    // Get specific book
                    if (isset($books[$id])) {
                        sendCorsHeaders();
                        header('Content-Type: application/json');
                        return [
                            'status' => 200,
                            'body' => json_encode($books[$id])
                        ];
                    } else {
                        sendCorsHeaders();
                        header('Content-Type: application/json');
                        return [
                            'status' => 404,
                            'body' => json_encode(['error' => 'Book not found'])
                        ];
                    }
                } else {
                    // Get all books
                    sendCorsHeaders();
                    header('Content-Type: application/json');
                    return [
                        'status' => 200,
                        'body' => json_encode(array_values($books))
                    ];
                }
            }
            break;

        case 'POST':
            if ($endpoint === 'book') {
                $data = json_decode($input, true);
                if (json_last_error() !== JSON_ERROR_NONE) {
                    sendCorsHeaders();
                    header('Content-Type: application/json');
                    return [
                        'status' => 400,
                        'body' => json_encode(['error' => 'Invalid JSON'])
                    ];
                }

                $book = new Book(
                    $data['title'] ?? '',
                    $data['author'] ?? '',
                    $data['description'] ?? null,
                    $data['coverImageUrl'] ?? null
                );
                $books[$book->bookId] = $book->toArray();
                saveBooks($books);

                sendCorsHeaders();
                header('Content-Type: application/json');
                return [
                    'status' => 201,
                    'body' => json_encode($book->toArray())
                ];
            }
            break;

        case 'PUT':
            if ($endpoint === 'book' && $id) {
                if (!isset($books[$id])) {
                    sendCorsHeaders();
                    header('Content-Type: application/json');
                    return [
                        'status' => 404,
                        'body' => json_encode(['error' => 'Book not found'])
                    ];
                }

                $data = json_decode($input, true);
                if (json_last_error() !== JSON_ERROR_NONE) {
                    sendCorsHeaders();
                    header('Content-Type: application/json');
                    return [
                        'status' => 400,
                        'body' => json_encode(['error' => 'Invalid JSON'])
                    ];
                }

                $book = $books[$id];
                if (isset($data['title'])) $book['title'] = $data['title'];
                if (isset($data['author'])) $book['author'] = $data['author'];
                if (array_key_exists('description', $data)) $book['description'] = $data['description'];
                if (array_key_exists('coverImageUrl', $data)) $book['coverImageUrl'] = $data['coverImageUrl'];
                $books[$id] = $book;
                saveBooks($books);

                sendCorsHeaders();
                header('Content-Type: application/json');
                return [
                    'status' => 200,
                    'body' => json_encode($book->toArray())
                ];
            }
            break;

        case 'DELETE':
            if ($endpoint === 'book' && $id) {
                if (isset($books[$id])) {
                    unset($books[$id]);
                    saveBooks($books);
                    sendCorsHeaders();
                    return ['status' => 204];
                } else {
                    sendCorsHeaders();
                    header('Content-Type: application/json');
                    return [
                        'status' => 404,
                        'body' => json_encode(['error' => 'Book not found'])
                    ];
                }
            }
            break;
    }

    // Not found
    sendCorsHeaders();
    header('Content-Type: application/json');
    return [
        'status' => 404,
        'body' => json_encode(['error' => 'Not found'])
    ];
}

// Main server logic
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$input = file_get_contents('php://input');

$response = handleRequest($method, $path, $input);

http_response_code($response['status']);
if (isset($response['body'])) {
    echo $response['body'];
}

?>