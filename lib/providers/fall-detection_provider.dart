import 'package:fall_detection/database/notify_database.dart';
import 'package:flutter/cupertino.dart';

class FallDetectionProvider extends ChangeNotifier {
  bool isFallDetectionEnabled = true;

  FallDetectionProvider() {
    _loadFallDetectionStatus();
  }

  Future<void> _loadFallDetectionStatus() async {
    final status = await NotifyDatabase.getFallDetectionStatus();
    isFallDetectionEnabled = status ?? true;
    notifyListeners();
  }

  Future<void> toggleFallDetection(bool value) async {
    isFallDetectionEnabled = value;
    notifyListeners();
    await NotifyDatabase.saveFallDetectionStatus(value);
  }
}