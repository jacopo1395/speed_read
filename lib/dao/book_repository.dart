import 'package:speed_read/models/book.dart';
import 'package:speed_read/service/local_storage.service.dart';
import 'package:sqflite/sqflite.dart';


class BookRepository {

  Future<List<Book>?> findAll() async {
    final client = await LocalStorageService().db;
    final maps = await client.query('book');
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<Book?> findById(int id) async {
    final client = await LocalStorageService().db;
    final elem = await client.query('book', where: 'id = ?', whereArgs: [id]);
    return Book.fromMap(elem[0]);
  }

  Future<int> save(Book book) async {
    var client = await LocalStorageService().db;
    return await client.insert(
      'book',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Book book) async {
    var client = await LocalStorageService().db;
    return client.update('book', book.toMap(),
        where: 'id = ?',
        whereArgs: [book.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> delete(int id) async {
    var client = await LocalStorageService().db;
    return client.delete('book', where: 'id = ?', whereArgs: [id]);
  }

}
