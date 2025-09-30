using System.ComponentModel.DataAnnotations;

namespace BookApi;

public class CreateBookDto
{
    [Required]
    public required string Title { get; set; }
    [Required]
    public required string Author { get; set; }
    [Required]
    public required string Description { get; set; }
    [Required]
    public required string CoverImageUrl { get; set; }
}