import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/data/provider/tasks_provider.dart';
import 'package:task_manager/services/sqldb_connection.dart';

class CategoriesProvider extends ModelProvider {
  SQLiteConnectionService? _sqlDbConnector;
  Database? _db;

  @override
  String get tableName => 'Categories';
  @override
  bool get isInitialized => _db != null ? _db!.isOpen : false;
  @override
  Database? get db => _db;

  bool _initializing = false;


  @override
  FutureOr<void> init() async {
    if (isInitialized || _initializing) {
      print('LOG: CategoriesProvider already initialized.');
      return;
    }
    _initializing = true; 
    _sqlDbConnector ??= SQLiteConnectionService.instance;
    _db = (await _sqlDbConnector!.db)!;
    _initializing = false; 
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

  Future<List<CategoryModel>> readCategories({
    String? where,
    List<Object?>? whereArgs,
    List<String>? columns,
    int? limit,
    String? groupBy,
    int? offset,
    String? orderBy,
  }) async {
    final data = await _db!.query(_tableName,
        where: where,
        whereArgs: whereArgs,
        columns: columns,
        limit: limit,
        groupBy: groupBy,
        offset: offset,
        orderBy: orderBy);
    return data.map((e) => CategoryModel.fromMap(e)).toList();
  }
}
