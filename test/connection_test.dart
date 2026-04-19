import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:logbook_app_001/services/mongo_service.dart'; 
import 'package:logbook_app_001/helpers/log.helper.dart'; 

void main() {
  const String sourceFile = "connection_test.dart";

  setUpAll(() async {
    // --- SOLUSI UTAMA ---
    // Memaksa mesin Flutter menyala di mode Test agar bisa membaca file .env
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null; 
    await dotenv.load(fileName: ".env");
  });

  test('Memastikan koneksi ke MongoDB Atlas berhasil', () async {
    final mongoService = MongoService();
    await LogHelper.writeLog("--- START CONNECTION TEST ---", source: sourceFile);

    try {
      await mongoService.connect();
      expect(dotenv.env['MONGODB_URI'], isNotNull);
      
      await LogHelper.writeLog("SUCCESS: Koneksi Atlas Terverifikasi", source: sourceFile, level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Kegagalan koneksi - $e", source: sourceFile, level: 1);
      fail("Koneksi gagal: $e");
    } finally {
      await mongoService.close();
      await LogHelper.writeLog("--- END TEST ---", source: sourceFile);
    }
  });
}