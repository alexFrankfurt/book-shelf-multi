import { Injectable, OnModuleInit } from '@nestjs/common';
import { CreateBookDto } from '../book/dto/create-book.dto';
import { UpdateBookDto } from '../book/dto/update-book.dto';
import { Book } from '../book/interfaces/book.interface';
import { DatabaseService } from './database.service';
import * as oracledb from 'oracledb';
import * as crypto from 'crypto';

@Injectable()
export class OracleService implements DatabaseService, OnModuleInit {
  async onModuleInit() {
    await this.ensureTableExists();
  }

  private async getConnection(): Promise<oracledb.Connection> {
    return oracledb.getConnection({
      user: process.env.ORACLE_USER,
      password: process.env.ORACLE_PASSWORD,
      connectionString: process.env.ORACLE_CONNECTION_STRING,
    });
  }

  private async ensureTableExists() {
    const connection = await this.getConnection();
    try {
      await connection.execute(
        `CREATE TABLE books (
          id VARCHAR2(36) PRIMARY KEY,
          title VARCHAR2(255) NOT NULL,
          author VARCHAR2(255) NOT NULL,
          description VARCHAR2(4000),
          coverImageUrl VARCHAR2(2048)
        )`
      );
    } catch (error) {
      // ORA-00955: name is already used by an existing object - table already exists
      if (error.errorNum !== 955) {
        throw error;
      }
    }
    await connection.close();
  }

  async findAll(): Promise<Book[]> {
    const connection = await this.getConnection();
    const result = await connection.execute('SELECT * FROM books');
    await connection.close();
    return result.rows as Book[];
  }

  async findOne(id: string): Promise<Book> {
    const connection = await this.getConnection();
    const result = await connection.execute('SELECT * FROM books WHERE id = :id', [id]);
    await connection.close();
    return result.rows[0] as Book;
  }

  async create(createBookDto: CreateBookDto): Promise<Book> {
    const connection = await this.getConnection();
    const id = crypto.randomUUID();
    const book: Book = { id, ...createBookDto };
    await connection.execute(
      `INSERT INTO books (id, title, author, description, coverImageUrl) VALUES (:id, :title, :author, :description, :coverImageUrl)`,
      [id, book.title, book.author, book.description, book.coverImageUrl]
    );
    await connection.commit();
    await connection.close();
    return book;
  }

  async update(id: string, updateBookDto: UpdateBookDto): Promise<Book> {
    const connection = await this.getConnection();
    const book = await this.findOne(id);
    const updatedBook = { ...book, ...updateBookDto };
    await connection.execute(
      `UPDATE books SET title = :title, author = :author, description = :description, coverImageUrl = :coverImageUrl WHERE id = :id`,
      [updatedBook.title, updatedBook.author, updatedBook.description, updatedBook.coverImageUrl, id]
    );
    await connection.commit();
    await connection.close();
    return updatedBook;
  }

  async delete(id: string): Promise<void> {
    const connection = await this.getConnection();
    await connection.execute('DELETE FROM books WHERE id = :id', [id]);
    await connection.commit();
    await connection.close();
  }
}
