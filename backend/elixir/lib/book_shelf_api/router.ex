defmodule BookShelfApi.Router do
  use Plug.Router
  use Agent

  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  # CORS headers helper
  defp cors_headers do
    %{
      "access-control-allow-origin" => "*",
      "access-control-allow-methods" => "GET, POST, PUT, DELETE, OPTIONS",
      "access-control-allow-headers" => "content-type"
    }
  end

  # Handle OPTIONS requests
  options "/book" do
    conn
    |> merge_resp_headers(cors_headers())
    |> send_resp(200, "")
  end

  options "/book/:id" do
    conn
    |> merge_resp_headers(cors_headers())
    |> send_resp(200, "")
  end

  # In-memory storage using Agent
  @books_agent __MODULE__

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @books_agent)
  end

  def get_books do
    Agent.get(@books_agent, & &1)
  end

  def get_book(id) do
    Agent.get(@books_agent, &Map.get(&1, id))
  end

  def put_book(book) do
    Agent.update(@books_agent, &Map.put(&1, book.bookId, book))
  end

  def delete_book(id) do
    Agent.get_and_update(@books_agent, fn books ->
      {Map.get(books, id), Map.delete(books, id)}
    end)
  end

  # GET /book - Get all books
  get "/book" do
    books = get_books() |> Map.values()
    conn
    |> merge_resp_headers(cors_headers())
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(books))
  end

  # GET /book/:id - Get a specific book
  get "/book/:id" do
    case get_book(id) do
      nil ->
        conn
        |> merge_resp_headers(cors_headers())
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{error: "Book not found"}))

      book ->
        conn
        |> merge_resp_headers(cors_headers())
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(book))
    end
  end

  # POST /book - Create a new book
  post "/book" do
    %{"title" => title, "author" => author} = conn.body_params
    description = Map.get(conn.body_params, "description")
    coverImageUrl = Map.get(conn.body_params, "coverImageUrl")

    book_id = UUID.uuid4()
    book = %{
      bookId: book_id,
      title: title,
      author: author,
      description: description,
      coverImageUrl: coverImageUrl
    }

    # Update in-memory storage (note: this won't persist across restarts)
    put_book(book)

    conn
    |> merge_resp_headers(cors_headers())
    |> put_resp_content_type("application/json")
    |> send_resp(201, Jason.encode!(book))
  end

  # PUT /book/:id - Update a book
  put "/book/:id" do
    case get_book(id) do
      nil ->
        conn
        |> merge_resp_headers(cors_headers())
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{error: "Book not found"}))

      book ->
        updated_book = %{
          bookId: book.bookId,
          title: Map.get(conn.body_params, "title", book.title),
          author: Map.get(conn.body_params, "author", book.author),
          description: Map.get(conn.body_params, "description", book.description),
          coverImageUrl: Map.get(conn.body_params, "coverImageUrl", book.coverImageUrl)
        }

        put_book(updated_book)

        conn
        |> merge_resp_headers(cors_headers())
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(updated_book))
    end
  end

  # DELETE /book/:id - Delete a book
  delete "/book/:id" do
    case delete_book(id) do
      nil ->
        conn
        |> merge_resp_headers(cors_headers())
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{error: "Book not found"}))

      _book ->
        conn
        |> merge_resp_headers(cors_headers())
        |> send_resp(204, "")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
