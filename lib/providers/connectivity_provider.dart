// lib/providers/connectivity_provider.dart
import 'package:brainmoto_app/service/offline_service.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = true;
  int _pendingSyncCount = 0;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isOnline => _isOnline;
  int get pendingSyncCount => _pendingSyncCount;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  ConnectivityProvider() {
    _initializeConnectivity();
    _startListening();
  }

  Future<void> _initializeConnectivity() async {
    _isOnline = await OfflineService.isOnline();
    _pendingSyncCount = await OfflineService.getPendingSyncCount();
    _lastSyncTime = await OfflineService.getLastSyncTime();
    notifyListeners();

    if (_isOnline && _pendingSyncCount > 0) {
      await syncPendingData();
    }
  }

  void _startListening() {
    OfflineService.connectivityStream.listen((result) async {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();

      if (wasOffline && _isOnline) {
        // Just came back online
        await Future.delayed(const Duration(seconds: 2));
        await syncPendingData();
      }
    });
  }

  Future<void> syncPendingData() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    notifyListeners();

    final result = await OfflineService.syncAllPendingData();

    _pendingSyncCount = await OfflineService.getPendingSyncCount();
    _lastSyncTime = await OfflineService.getLastSyncTime();
    _isSyncing = false;
    notifyListeners();
  }

  Future<void> updatePendingCount() async {
    _pendingSyncCount = await OfflineService.getPendingSyncCount();
    notifyListeners();
  }
}
