import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/data/provider/tasks_provider.dart';
import 'package:task_manager/services/sqldb_connection.dart';

class CategoriesProvider extends ModelProvider {
  SQLiteConnectionService? _sqlDbConnector;
  Database? _db;

  bool get isInitialized => _db != null ? _db!.isOpen : false;

  @override
  FutureOr<void> init() async {
    if (isInitialized) {
      print('LOG: CategoriesProvider already initialized.');
      return;
    }
    _sqlDbConnector ??= SQLiteConnectionService.instance;
    _db = (await _sqlDbConnector!.db)!;
    print('LOG: CategoriesProvider initialized.');
  }

  @override
  FutureOr<void> dispose() async {
    if (!isInitialized) {
      print('LOG: CategoriesProvider already disposed.');
      return;
    }
    await _db!.close();
    await _sqlDbConnector!.closeDatabase();
    print('LOG: CategoriesProvider disposed.');
  }

  final _tableName = 'Categories';
  Future<int> createCategory(CategoryModel data) async {
    return _db!.insert(_tableName, data.toMap());
  }

  Future<int> deleteCategory(int id) async {
    return _db!.delete(_tableName, where: 'id = $id');
  }

  Future<int> updateCategory(
      int id, CategoryModel Function(CategoryModel oldData) newData) async {
    dynamic oldData = await _db!.query(_tableName, where: 'id = $id');
    oldData = CategoryModel.fromMap(oldData.first);
    return _db!.update(_tableName, newData(oldData).toMap(), where: 'id = $id');
  }

  Future<List<CategoryModel>> readCategories({String? where, List<Object?>? whereArgs}) async {
    final data = await _db!.query(_tableName, where:  where, whereArgs:  whereArgs);
    return data.map((e) => CategoryModel.fromMap(e)).toList();
  }
}
