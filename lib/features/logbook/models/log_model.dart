import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id; 
  final String title;
  final String description;
  final String date;
  final String category;

  LogModel({
    this.id, 
    required this.title, 
    required this.description, 
    required this.date, 
    required this.category
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null ? map['date'].toString() : DateTime.now().toString().substring(0, 16),
      category: map['category'] ?? 'Pribadi',
    );
  }

  Map<String, dynamic> toMap() => {
    '_id': id ?? ObjectId(), 
    'title': title,
    'description': description,
    'date': date,
    'category': category,
  };
}