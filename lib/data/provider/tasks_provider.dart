import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/services/sqldb_connection.dart';

abstract class ModelProvider {
  bool get isInitialized;
  Database? get db;
  String get tableName;
  FutureOr<void> init();
  FutureOr<void> dispose();
}

class TasksProvider extends ModelProvider {
  SQLiteConnectionService? _sqlDbConnector;
  Database? _db;

  @override
  String get tableName => 'Tasks';

  @override
  bool get isInitialized => _db != null ? _db!.isOpen : false;
  @override
  Database? get db => _db;

  @override
  FutureOr<void> init() async {
    if (isInitialized) {
      print('LOG: TasksProvider already initialized.');
      return;
    }
    _sqlDbConnector ??= SQLiteConnectionService.instance;
    _db = (await _sqlDbConnector!.db)!;
    print('LOG: TasksProvider initialized.');
  }

  @override
  FutureOr<void> dispose() async {
    if (!isInitialized) {
      print('LOG: TasksProvider already disposed.');
      return;
    }
    await _db!.close();
    await _sqlDbConnector!.closeDatabase();
    print('LOG: TasksProvider disposed.');
  }

  final _tableName = 'Tasks';
  Future<int> createTask(TaskModel data) async {
    return _db!.insert(_tableName, data.toMap());
  }

  Future<int> deleteTask(int id) async {
    return _db!.delete(_tableName, where: 'id = $id');
  }

  Future<int> updateTask(
      int id, TaskModel Function(TaskModel oldData) newData) async {
    dynamic oldData = await _db!.query(_tableName, where: 'id = $id');
    oldData = TaskModel.fromMap(oldData.first);
    return _db!.update(_tableName, newData(oldData).toMap(), where: 'id = $id');
  }

  Future<List<TaskModel>> readTasks({
    String? where,
    List<Object?>? whereArgs,
    List<String>? columns,
    int? limit,
    String? groupBy,
    int? offset,
    String? orderBy,
  }) async {
    final data = await _db!.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      columns: columns,
      limit: limit,
      offset: offset,
      groupBy: groupBy,
      orderBy: orderBy,
    );
    return data.map((e) => TaskModel.fromMap(e)).toList();
  }
}
