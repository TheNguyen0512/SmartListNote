import 'package:smartlist/features/notes/domain/entities/note.dart';

enum OperationType { add, update, delete }

class Operation {
  final OperationType type;
  final Note? note;
  final String? id;
  final DateTime timestamp;
  final bool synced; // Thêm trường này

  Operation({
    required this.type,
    this.note,
    this.id,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'note': note?.toJson(),
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  factory Operation.fromJson(Map<String, dynamic> json) => Operation(
        type: OperationType.values.firstWhere((e) => e.toString() == json['type']),
        note: json['note'] != null ? Note.fromJson(json['note']) : null,
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        synced: json['synced'] ?? false,
      );
}