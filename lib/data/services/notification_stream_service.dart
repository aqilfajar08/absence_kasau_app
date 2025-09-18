import 'dart:async';
import 'notification_service.dart';

class NotificationStreamService {
  static final NotificationStreamService _instance = NotificationStreamService._internal();
  factory NotificationStreamService() => _instance;
  NotificationStreamService._internal();

  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();
  
  // Stream that emits unread notification count changes
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  
  // Current unread count
  int _currentUnreadCount = 0;
  
  // Initialize the service
  Future<void> initialize() async {
    await _updateUnreadCount();
  }
  
  // Update unread count and notify listeners
  Future<void> _updateUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (_currentUnreadCount != count) {
        _currentUnreadCount = count;
        _unreadCountController.add(count);
      }
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Call this when a new notification is added
  Future<void> onNotificationAdded() async {
    await _updateUnreadCount();
  }
  
  // Call this when a notification is marked as read
  Future<void> onNotificationRead() async {
    await _updateUnreadCount();
  }
  
  // Call this when all notifications are cleared
  Future<void> onNotificationsCleared() async {
    await _updateUnreadCount();
  }
  
  // Get current unread count
  int get currentUnreadCount => _currentUnreadCount;
  
  // Dispose the stream controller
  void dispose() {
    _unreadCountController.close();
  }
}
