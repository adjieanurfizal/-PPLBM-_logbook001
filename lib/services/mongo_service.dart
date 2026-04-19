import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/helpers/log.helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  DbCollection? _collection;
  final String _source = "mongo_service.dart";

  factory MongoService() => _instance;
  MongoService._internal();

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) await connect();
    return _collection!;
  }

  Future<void> connect() async {
    try {
      final dbUri = dotenv.env['MONGODB_URI'];
      if (dbUri == null) throw Exception("URI Kosong");
      _db = await Db.create(dbUri);
      await _db!.open();
      _collection = _db!.collection('logs');
      await LogHelper.writeLog("Koneksi Sukses!", source: _source);
    } catch (e) {
      await LogHelper.writeLog("Error Koneksi: $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<List<LogModel>> getLogs() async {
    final col = await _getSafeCollection();
    final data = await col.find().toList();
    return data.map((e) => LogModel.fromMap(e)).toList();
  }

  Future<void> insertLog(LogModel log) async {
    final col = await _getSafeCollection();
    await col.insertOne(log.toMap());
  }

  Future<void> updateLog(LogModel log) async {
    final col = await _getSafeCollection();
    await col.replaceOne(where.id(ObjectId.fromHexString(log.id!)), log.toMap());
  }

  Future<void> deleteLog(ObjectId id) async {
    final col = await _getSafeCollection();
    await col.remove(where.id(id));
  }

  Future<void> close() async {}
}