import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String TASKS_TABLE_CREATE_SQLQUERY = """
      CREATE TABLE Tasks(
        id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        title  INTEGER NOT NULL,
        descreption  TEXT NULL,
        category  INTEGER NOT NULL,
        creation_date DATETIME,
        priority  TEXT NULL DEFAULT 'MEDIUM',
        termination_date  DATETIME NULL,
        completion_date  DATETIME NOT NULL,
        completed  TINYINT NOT NULL,
          FOREIGN KEY (category)
          REFERENCES  Categories  (id)
          ON DELETE NO ACTION
          ON UPDATE NO ACTION);
      """;
const String CATEGORIES_TABLE_CREATE_SQLQUERY = """
      CREATE TABLE Categories(
        id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        title  TEXT NOT NULL,
        color_code  TEXT NULL,
        productivity_percentag  INTEGER NULL,
        tasks_number  INTEGER NOT NULL DEFAULT 0
      )
      """;
const String INITIAL_DATA_INSERTATION_SQLQUERY = """
      INSERT INTO Categories(title,color_code) VALUES("My Category", 4287758251)
""";

class SQLiteConnectionService {
  SQLiteConnectionService._();

  static SQLiteConnectionService? _instance;
  static SQLiteConnectionService get instance {
    _instance ??= SQLiteConnectionService._();
    return _instance!;
  }

  static const DATABASE_NAME = "TaskManagerDBTest.db";
  static const DATABASE_VERSION = 1;
  Database? _db;

  Future<Database?> get db async {
    if (_db == null)
      return GetPlatform.isDesktop
          ? initialDesktopDataBase()
          : initialMobileDataBase();
    else
      return _db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        TASKS_TABLE_CREATE_SQLQUERY + CATEGORIES_TABLE_CREATE_SQLQUERY);
    await db.rawInsert(INITIAL_DATA_INSERTATION_SQLQUERY);
    print('LOG: database onCreate function executed.');
  }

  Future<Database> initialMobileDataBase() async {
    print("LOG: start initialization of mobile database");
    final String path = join(await getDatabasesPath(), DATABASE_NAME);
    _db = await openDatabase(path, onCreate: _onCreate);
    print("LOG: finish initialization of mobile database");
    return _db!;
  }

  Future<Database> initialDesktopDataBase() async {
    print("LOG: start initialization of desktop database");
    sqfliteFfiInit();
    final String path =
        join(await databaseFactoryFfi.getDatabasesPath(), DATABASE_NAME);

    _db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        onCreate: _onCreate,
        version: DATABASE_VERSION,
      ),
    );
    print("LOG: finish initialization of desktop database");
    return _db!;
  }

  void closeDatabase() async {
    await _db?.close();
    print("LOG: close database");
  }
}
