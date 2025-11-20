// lib/models/sync_queue_model.dart
class SyncQueueModel {
  final String id;
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final String operation; // 'create', 'update', 'delete'
  final DateTime createdAt;
  final int retryCount;

  SyncQueueModel({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.operation,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory SyncQueueModel.fromJson(Map<String, dynamic> json) {
    return SyncQueueModel(
      id: json['id'],
      collection: json['collection'],
      documentId: json['documentId'],
      data: Map<String, dynamic>.from(json['data']),
      operation: json['operation'],
      createdAt: DateTime.parse(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
    );
  }
}
