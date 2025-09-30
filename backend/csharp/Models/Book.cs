namespace BookApi;

public class Book
{
    public string? Id { get; set; }
    public required string Title { get; set; }
    public required string Author { get; set; }
    public required string Description { get; set; }
    public required string CoverImageUrl { get; set; }
}