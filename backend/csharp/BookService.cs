namespace BookApi;

public class BookService
{
    private readonly Dictionary<string, Book> _books = new();
    private int _nextId = 1;

    public Task<List<Book>> FindAllAsync()
    {
        return Task.FromResult(_books.Values.ToList());
    }

    public Task<Book?> FindOneAsync(string id)
    {
        _books.TryGetValue(id, out var book);
        return Task.FromResult(book);
    }

    public Task<Book> CreateAsync(CreateBookDto dto)
    {
        var id = _nextId++.ToString();
        var book = new Book
        {
            Id = id,
            Title = dto.Title,
            Author = dto.Author,
            Description = dto.Description,
            CoverImageUrl = dto.CoverImageUrl
        };
        _books[id] = book;
        return Task.FromResult(book);
    }

    public Task<Book?> UpdateAsync(string id, UpdateBookDto dto)
    {
        if (!_books.TryGetValue(id, out var book))
        {
            return Task.FromResult<Book?>(null);
        }

        if (dto.Title is not null) book.Title = dto.Title;
        if (dto.Author is not null) book.Author = dto.Author;
        if (dto.Description is not null) book.Description = dto.Description;
        if (dto.CoverImageUrl is not null) book.CoverImageUrl = dto.CoverImageUrl;

        return Task.FromResult<Book?>(book);
    }

    public Task DeleteAsync(string id)
    {
        _books.Remove(id);
        return Task.CompletedTask;
    }
}