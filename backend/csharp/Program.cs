using BookApi;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<BookService>();
builder.Services.AddCors();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(policy => policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
app.UseHttpsRedirection();

var bookGroup = app.MapGroup("/book");

bookGroup.MapPost("/", async (BookService service, CreateBookDto dto) =>
{
    var book = await service.CreateAsync(dto);
    return Results.Created($"/book/{book.Id}", book);
});

bookGroup.MapGet("/", async (BookService service) =>
{
    var books = await service.FindAllAsync();
    return Results.Ok(books);
});

bookGroup.MapGet("/{id}", async (BookService service, string id) =>
{
    var book = await service.FindOneAsync(id);
    return book is not null ? Results.Ok(book) : Results.NotFound();
});

bookGroup.MapPut("/{id}", async (BookService service, string id, UpdateBookDto dto) =>
{
    var book = await service.UpdateAsync(id, dto);
    return book is not null ? Results.Ok(book) : Results.NotFound();
});

bookGroup.MapDelete("/{id}", async (BookService service, string id) =>
{
    await service.DeleteAsync(id);
    return Results.NoContent();
});

app.Run();