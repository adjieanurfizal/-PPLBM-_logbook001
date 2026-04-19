import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart'; // Import service cloud kita

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]); 

  LogController(); // Tidak langsung load disk lagi, UI yang akan trigger

  // --- PENCARIAN (Tetap Sama) ---
  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // --- CRUD CLOUD ---
  Future<void> loadFromCloud() async {
    final data = await MongoService().getLogs();
    logsNotifier.value = data;
    filteredLogs.value = data; 
  }

  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toString().substring(0, 16),
      category: category,
    );
    
    await MongoService().insertLog(newLog); // Simpan ke Cloud
    await loadFromCloud(); // Refresh data di layar
  }

  Future<void> updateLog(int index, String title, String desc, String category) async {
    final targetLog = filteredLogs.value[index];

    final updatedLog = LogModel(
      id: targetLog.id, // ID asli dari MongoDB wajib disertakan
      title: title, 
      description: desc, 
      date: DateTime.now().toString().substring(0, 16),
      category: category,
    );
    
    await MongoService().updateLog(updatedLog); // Update ke Cloud
    await loadFromCloud(); // Refresh data di layar
  }

  Future<void> removeLog(int index) async {
    final targetLog = filteredLogs.value[index];
    
    if (targetLog.id != null) {
      await MongoService().deleteLog(targetLog.id!); // Hapus di Cloud
      await loadFromCloud(); // Refresh data di layar
    }
  }
}