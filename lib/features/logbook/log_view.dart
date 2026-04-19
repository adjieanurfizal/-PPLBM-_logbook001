import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/services/access_control_service.dart'; // Gatekeeper
import 'package:logbook_app_001/features/logbook/log_editor_page.dart'; // Editor Baru

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  bool _isLoading = true;

  // --- MOCK USER UNTUK MODUL 5 ---
  // Ubah 'role' menjadi 'Ketua' untuk melihat perbedaannya nanti!
  final Map<String, dynamic> currentUser = {
    'uid': 'user_123', 
    'role': 'Anggota', 
    'teamId': 'Kelompok_2'
  };

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      if (await _controller.hasInternet()) {
        await MongoService().connect(); 
      }
      await _controller.syncData(); 
    } catch (e) {
      // Abaikan error, kita pakai data Hive
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username} (${currentUser['role']})"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sinkronisasi Manual',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menyinkronkan...")));
              _initData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (route) => false);
            },
          ),
        ],
      ),
      
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => _controller.searchLog(value),
              decoration: InputDecoration(
                labelText: "Cari Catatan...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs, 
              builder: (context, currentLogs, child) {
                if (currentLogs.isEmpty) {
                  return const Center(child: Text("Belum ada catatan."));
                }

                return ListView.builder(
                  itemCount: currentLogs.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final log = currentLogs[index];
                    
                    // --- GATEKEEPER LOGIC ---
                    bool isOwner = log.authorId == currentUser['uid'];
                    bool canEdit = AccessControlService.canPerform(currentUser['role'], AccessControlService.actionUpdate, isOwner: isOwner);
                    bool canDelete = AccessControlService.canPerform(currentUser['role'], AccessControlService.actionDelete, isOwner: isOwner);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${log.category} • ${log.date.substring(0, 10)}\nPenulis: ${log.authorId}", maxLines: 2),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (canEdit)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openEditor(log: log, index: index),
                              ),
                            if (canDelete)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await _controller.removeLog(index);
                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dihapus!")));
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(), // Buka editor baru kosong
        child: const Icon(Icons.add),
      ),
    );
  }
}