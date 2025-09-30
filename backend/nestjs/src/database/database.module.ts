import { Module, DynamicModule, Provider, Global } from '@nestjs/common';
import { MongooseModule, getModelToken } from '@nestjs/mongoose';
import { Book, BookSchema, BookDocument } from './schemas/book.schema';
import { Model } from 'mongoose';
import { MongoService } from './mongo.service';
import { OracleService } from './oracle.service';
import { DatabaseService } from './database.service';
import { InMemoryService } from './in-memory.service';

@Global()
@Module({})
export class DatabaseModule {
  static register(): DynamicModule {
    const providers: Provider[] = [
      {
        provide: DatabaseService,
        useFactory: (bookModel?: Model<BookDocument>) => {
          if (process.env.DB_TYPE === 'mongodb') {
            return new MongoService(bookModel!);
          } else if (process.env.DB_TYPE === 'oracledb') {
            return new OracleService();
          } else {
            return new InMemoryService();
          }
        },
        inject: process.env.DB_TYPE === 'mongodb' ? [getModelToken(Book.name)] : [],
      },
    ];

    const imports: any[] = [];
    if (process.env.DB_TYPE === 'mongodb') {
      imports.push(MongooseModule.forRoot(process.env.MONGO_URI || 'mongodb://localhost/book-shelf'));
      imports.push(MongooseModule.forFeature([{ name: Book.name, schema: BookSchema }]));
    }

    return {
      module: DatabaseModule,
      imports,
      providers,
      exports: [DatabaseService],
    };
  }
}

