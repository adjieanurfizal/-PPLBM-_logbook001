// ignore_for_file: unnecessary_type_check

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Box;
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);
  
  // Membuka brankas lokal Hive
  final Box<LogModel> _localBox = Hive.box<LogModel>('offline_logs');

  LogController();

  // --- CEK INTERNET PINTAR ---
  Future<bool> hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult is List) {
      return !connectivityResult.contains(ConnectivityResult.none);
    }
  }

  // --- SINKRONISASI (OFFLINE-FIRST) ---
  Future<void> syncData() async {
    try {
      if (await hasInternet()) {
        // Jika Online: Ambil dari Cloud, timpa ke Lokal
        final cloudData = await MongoService().getLogs();
        await _localBox.clear();
        await _localBox.addAll(cloudData);
      }
    } catch (e) {
      // Abaikan jika gagal, kita tetap punya data lokal
    }
    _loadFromLocal();
  }

  void _loadFromLocal() {
    final data = _localBox.values.toList();
    // Urutkan dari yang terbaru
    data.sort((a, b) => b.date.compareTo(a.date));
    logsNotifier.value = data;
    filteredLogs.value = data;
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // --- CRUD (HYBRID CLOUD + LOKAL) ---
  Future<void> addLog(String title, String desc, String authorId, String teamId, String category) async {
    final newLog = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString().substring(0, 16),
      authorId: authorId,
      teamId: teamId,
      category: category,
    );
    
    if (await hasInternet()) {
      await MongoService().insertLog(newLog); // Kirim ke satelit
    }
    await _localBox.add(newLog); // Simpan di HP
    await syncData();
  }

  Future<void> updateLog(int index, String title, String desc, String category) async {
    final targetLog = filteredLogs.value[index];
    final updatedLog = LogModel(
      id: targetLog.id, 
      title: title, 
      description: desc, 
      date: DateTime.now().toString().substring(0, 16),
      authorId: targetLog.authorId,
      teamId: targetLog.teamId,
      category: category,
    );
    
    if (await hasInternet()) {
      await MongoService().updateLog(updatedLog);
    }
    
    // Update lokal (mencari index asli di Hive)
    final realIndex = _localBox.values.toList().indexWhere((e) => e.date == targetLog.date);
    if(realIndex != -1) await _localBox.putAt(realIndex, updatedLog);
    
    await syncData();
  }

  Future<void> removeLog(int index) async {
    final targetLog = filteredLogs.value[index];
    
    if (await hasInternet() && targetLog.id != null) {
      await MongoService().deleteLog(ObjectId.fromHexString(targetLog.id!));
    }
    
    final realIndex = _localBox.values.toList().indexWhere((e) => e.date == targetLog.date);
    if(realIndex != -1) await _localBox.deleteAt(realIndex);
    
    await syncData();
  }
}