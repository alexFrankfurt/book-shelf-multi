import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateBookDto } from '../book/dto/create-book.dto';
import { UpdateBookDto } from '../book/dto/update-book.dto';
import { Book } from '../book/interfaces/book.interface';
import { DatabaseService } from './database.service';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class InMemoryService implements DatabaseService {
  private books: Book[] = [];

  async findAll(): Promise<Book[]> {
    return this.books;
  }

  async findOne(id: string): Promise<Book> {
    const book = this.books.find(book => book.id === id);
    if (!book) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }
    return book;
  }

  async create(createBookDto: CreateBookDto): Promise<Book> {
    const newBook: Book = { id: uuidv4(), ...createBookDto };
    this.books.push(newBook);
    return newBook;
  }

  async update(id: string, updateBookDto: UpdateBookDto): Promise<Book> {
    const index = this.books.findIndex(book => book.id === id);
    if (index === -1) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }
    this.books[index] = { ...this.books[index], ...updateBookDto };
    return this.books[index];
  }

  async delete(id: string): Promise<void> {
    const index = this.books.findIndex(book => book.id === id);
    if (index === -1) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }
    this.books.splice(index, 1);
  }
}
