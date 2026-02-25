import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final VoidCallback onEdit;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.onEdit,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan': return Colors.blue.shade100;
      case 'Prioritas Tinggi': return Colors.red.shade100;
      case 'Pribadi': return Colors.green.shade100;
      default: return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: _getCategoryColor(log.category),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        leading: const Icon(Icons.note_alt, color: Colors.black87),
        title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${log.category} • ${log.date}\n${log.description}"),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.black54),
          onPressed: onEdit, 
        ),
      ),
    );
  }
}