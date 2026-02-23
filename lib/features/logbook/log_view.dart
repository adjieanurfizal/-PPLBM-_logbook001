import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'package:logbook_app_001/features/logbook/widgets/log_item_widget.dart'; 

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // --- TAMBAH CATATAN ---
  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                _controller.addLog(_titleController.text, _contentController.text);
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Catatan berhasil ditambahkan!"), backgroundColor: Colors.green)
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Judul dan Isi tidak boleh kosong!"), backgroundColor: Colors.red)
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // --- EDIT CATATAN ---
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            const SizedBox(height: 10),
            TextField(controller: _contentController, maxLines: 3),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit dibatalkan!"))
                ); 
            },
            child: const Text("Batal")
          ),
          ElevatedButton(
            onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Konfirmasi Update"),
                    content: const Text("Yakin ingin memperbarui catatan ini?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: const Text("Batal")
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _controller.updateLog(index, _titleController.text, _contentController.text);
                          Navigator.pop(context); 
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Catatan berhasil diperbarui!"), backgroundColor: Colors.green)
                          );
                        },
                        child: const Text("Ya, Update"),
                      ),
                    ],
                  ),
                );  
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // --- TOMBOL LOGOUT ---
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi Logout"),
                  content: const Text("Apakah Anda yakin ingin keluar?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text("Batal")
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()),
                          (route) => false,
                        );
                      },
                      child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logsNotifier, 
        builder: (context, currentLogs, child) {
          
          if (currentLogs.isEmpty) {
            return const Center(child: Text("Belum ada catatan logbook."));
          }

          return ListView.builder(
            itemCount: currentLogs.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final log = currentLogs[index];
              
              // --- WIDGET KUSTOM ---
              return LogItemWidget(
                log: log,
                onEdit: () => _showEditLogDialog(index, log),
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Hapus Catatan?"),
                      content: Text("Yakin ingin menghapus '${log.title}'?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), 
                          child: const Text("Batal")
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () {
                            _controller.removeLog(index);
                            Navigator.pop(context); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Catatan berhasil dihapus!"),
                                backgroundColor: Colors.red,
                              )
                            );
                          },
                          child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}