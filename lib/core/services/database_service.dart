// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseService {
//   static const String _dbName = 'pharmacy_pos.db';
//   static const int _dbVersion = 1;

//   Future<Database> initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, _dbName);

//     return await openDatabase(
//       path,
//       version: _dbVersion,
//       // We leave onCreate empty or minimal because your LocalDatasources
//       // will handle their own "CREATE TABLE IF NOT EXISTS" logic.
//       onCreate: (db, version) async {},
//     );
//   }
// }
