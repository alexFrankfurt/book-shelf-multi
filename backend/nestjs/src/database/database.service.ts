import { CreateBookDto } from '../book/dto/create-book.dto';
import { UpdateBookDto } from '../book/dto/update-book.dto';
import { Book } from '../book/interfaces/book.interface';

export abstract class DatabaseService {
  abstract findAll(): Promise<Book[]>;
  abstract findOne(id: string): Promise<Book>;
  abstract create(createBookDto: CreateBookDto): Promise<Book>;
  abstract update(id: string, updateBookDto: UpdateBookDto): Promise<Book>;
  abstract delete(id: string): Promise<void>;
}
