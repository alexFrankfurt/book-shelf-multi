import { Injectable } from '@nestjs/common';
import { Book } from './interfaces/book.interface';
import { CreateBookDto } from './dto/create-book.dto';
import { UpdateBookDto } from './dto/update-book.dto';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class BookService {
  constructor(private readonly databaseService: DatabaseService) {}

  create(createBookDto: CreateBookDto): Promise<Book> {
    return this.databaseService.create(createBookDto);
  }

  findAll(): Promise<Book[]> {
    return this.databaseService.findAll();
  }

  findOne(id: string): Promise<Book> {
    return this.databaseService.findOne(id);
  }

  update(id: string, updateBookDto: UpdateBookDto): Promise<Book> {
    return this.databaseService.update(id, updateBookDto);
  }

  remove(id: string): Promise<void> {
    return this.databaseService.delete(id);
  }
}
