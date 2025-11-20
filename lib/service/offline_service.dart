// lib/services/offline_service.dart
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_queue_model.dart';
import '../models/assessment_model.dart';
import 'firebase_service.dart';
import 'package:uuid/uuid.dart';

class OfflineService {
  static const String _syncQueueKey = 'sync_queue';
  static const String _lastSyncKey = 'last_sync';
  static const Uuid _uuid = Uuid();

  static final Connectivity _connectivity = Connectivity();

  // Check if device is online
  static Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Listen to connectivity changes
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  // Add item to sync queue
  static Future<void> addToSyncQueue(SyncQueueModel item) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_syncQueueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueJson);

    queue.add(item.toJson());
    await prefs.setString(_syncQueueKey, jsonEncode(queue));
  }

  // Get sync queue
  static Future<List<SyncQueueModel>> getSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_syncQueueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueJson);

    return queue.map((item) => SyncQueueModel.fromJson(item)).toList();
  }

  // Clear sync queue
  static Future<void> clearSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_syncQueueKey, '[]');
  }

  // Remove item from sync queue
  static Future<void> removeFromSyncQueue(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_syncQueueKey) ?? '[]';
    final List<dynamic> queue = jsonDecode(queueJson);

    queue.removeWhere((item) => item['id'] == id);
    await prefs.setString(_syncQueueKey, jsonEncode(queue));
  }

  // Get pending sync count
  static Future<int> getPendingSyncCount() async {
    final queue = await getSyncQueue();
    return queue.length;
  }

  // Save assessment offline
  static Future<String> saveAssessmentOffline(
      AssessmentModel assessment) async {
    final assessmentId = _uuid.v4();

    // Add to sync queue
    final syncItem = SyncQueueModel(
      id: _uuid.v4(),
      collection: 'assessments',
      documentId: assessmentId,
      data: assessment.toFirestore(),
      operation: 'create',
      createdAt: DateTime.now(),
    );

    await addToSyncQueue(syncItem);

    // Also save to local storage for immediate access
    await _saveAssessmentLocally(assessmentId, assessment);

    return assessmentId;
  }

  // Save assessment locally
  static Future<void> _saveAssessmentLocally(
      String id, AssessmentModel assessment) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'assessment_$id';
    await prefs.setString(key, jsonEncode(assessment.toFirestore()));
  }

  // Get local assessments
  static Future<List<AssessmentModel>> getLocalAssessments() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('assessment_'));

    final List<AssessmentModel> assessments = [];
    for (var key in keys) {
      final json = prefs.getString(key);
      if (json != null) {
        final data = jsonDecode(json);
        final id = key.replaceFirst('assessment_', '');
        assessments.add(AssessmentModel.fromFirestore(data, id));
      }
    }

    return assessments;
  }

  // Sync all pending data
  static Future<SyncResult> syncAllPendingData() async {
    if (!await isOnline()) {
      return SyncResult(
          success: false, message: 'No internet connection', syncedCount: 0);
    }

    final queue = await getSyncQueue();
    if (queue.isEmpty) {
      return SyncResult(
          success: true, message: 'Nothing to sync', syncedCount: 0);
    }

    int syncedCount = 0;
    int failedCount = 0;
    List<String> errors = [];

    for (var item in queue) {
      try {
        await _syncItem(item);
        await removeFromSyncQueue(item.id);
        syncedCount++;
      } catch (e) {
        failedCount++;
        errors.add('Failed to sync ${item.collection}/${item.documentId}: $e');

        // Increase retry count
        if (item.retryCount < 3) {
          final updatedItem = SyncQueueModel(
            id: item.id,
            collection: item.collection,
            documentId: item.documentId,
            data: item.data,
            operation: item.operation,
            createdAt: item.createdAt,
            retryCount: item.retryCount + 1,
          );
          await removeFromSyncQueue(item.id);
          await addToSyncQueue(updatedItem);
        } else {
          // Remove after 3 failed attempts
          await removeFromSyncQueue(item.id);
        }
      }
    }

    // Update last sync time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

    if (failedCount == 0) {
      return SyncResult(
        success: true,
        message: 'Successfully synced $syncedCount items',
        syncedCount: syncedCount,
      );
    } else {
      return SyncResult(
        success: false,
        message: 'Synced $syncedCount items, $failedCount failed',
        syncedCount: syncedCount,
        errors: errors,
      );
    }
  }

  // Sync individual item
  static Future<void> _syncItem(SyncQueueModel item) async {
    switch (item.operation) {
      case 'create':
        if (item.collection == 'assessments') {
          await FirebaseService.createAssessment(
            AssessmentModel.fromFirestore(item.data, item.documentId),
          );
          // Remove from local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('assessment_${item.documentId}');
        }
        break;
      case 'update':
        if (item.collection == 'assessments') {
          await FirebaseService.updateAssessment(item.documentId, item.data);
        }
        break;
      case 'delete':
        if (item.collection == 'assessments') {
          await FirebaseService.deleteAssessment(item.documentId);
        }
        break;
    }
  }

  // Get last sync time
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_lastSyncKey);
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  // Auto sync when online
  static Future<void> startAutoSync() async {
    connectivityStream.listen((result) async {
      if (result != ConnectivityResult.none) {
        // Wait a bit for connection to stabilize
        await Future.delayed(const Duration(seconds: 2));
        await syncAllPendingData();
      }
    });
  }

  // Clear all offline data
  static Future<void> clearAllOfflineData() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove all assessment data
    final keys = prefs.getKeys().where((key) => key.startsWith('assessment_'));
    for (var key in keys) {
      await prefs.remove(key);
    }

    // Clear sync queue
    await clearSyncQueue();

    // Clear last sync time
    await prefs.remove(_lastSyncKey);
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final List<String>? errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    this.errors,
  });
}
