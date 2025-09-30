import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateBookDto } from '../book/dto/create-book.dto';
import { UpdateBookDto } from '../book/dto/update-book.dto';
import { Book, BookDocument } from './schemas/book.schema';
import { DatabaseService } from './database.service';

@Injectable()
export class MongoService implements DatabaseService {
  constructor(@InjectModel(Book.name) private readonly bookModel?: Model<BookDocument>) {}

  async findAll(): Promise<Book[]> {
    if (!this.bookModel) return [];
    return this.bookModel.find().exec();
  }

  async findOne(id: string): Promise<Book> {
    if (!this.bookModel) throw new NotFoundException('Database not configured');
    const book = await this.bookModel.findById(id).exec();
    if (!book) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }
    return book;
  }

  async create(createBookDto: CreateBookDto): Promise<Book> {
    if (!this.bookModel) throw new NotFoundException('Database not configured');
    const createdBook = new this.bookModel(createBookDto);
    return createdBook.save();
  }

  async update(id: string, updateBookDto: UpdateBookDto): Promise<Book> {
    if (!this.bookModel) throw new NotFoundException('Database not configured');
    const updatedBook = await this.bookModel.findByIdAndUpdate(id, updateBookDto, { new: true }).exec();
    if (!updatedBook) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }
    return updatedBook;
  }

  async delete(id: string): Promise<void> {
    if (!this.bookModel) throw new NotFoundException('Database not configured');
    const result = await this.bookModel.findByIdAndDelete(id).exec();
    if (!result) {
      throw new NotFoundException(`Book with ID ${id} not found`);
    }
  }
}
