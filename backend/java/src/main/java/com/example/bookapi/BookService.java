package com.example.bookapi;

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class BookService {
    private final Map<String, Book> books = new HashMap<>();
    private final AtomicLong idCounter = new AtomicLong(1);

    public List<Book> findAll() {
        return new ArrayList<>(books.values());
    }

    public Book findOne(String id) {
        return books.get(id);
    }

    public Book create(CreateBookDto dto) {
        String id = String.valueOf(idCounter.getAndIncrement());
        Book book = new Book(id, dto.getTitle(), dto.getAuthor(), dto.getDescription(), dto.getCoverImageUrl());
        books.put(id, book);
        return book;
    }

    public Book update(String id, UpdateBookDto dto) {
        Book book = books.get(id);
        if (book != null) {
            if (dto.getTitle() != null) book.setTitle(dto.getTitle());
            if (dto.getAuthor() != null) book.setAuthor(dto.getAuthor());
            if (dto.getDescription() != null) book.setDescription(dto.getDescription());
            if (dto.getCoverImageUrl() != null) book.setCoverImageUrl(dto.getCoverImageUrl());
        }
        return book;
    }

    public void delete(String id) {
        books.remove(id);
    }
}