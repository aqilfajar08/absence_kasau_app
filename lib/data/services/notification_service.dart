import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';

class NotificationService {
  static const String _notificationsKey = 'notifications';
  
  // Get all notifications
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson == null) {
        return [];
      }
      
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      return notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Add a new notification
  static Future<void> addNotification(NotificationModel notification) async {
    try {
      final List<NotificationModel> notifications = await getNotifications();
      notifications.insert(0, notification); // Add to beginning
      
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = json.encode(
        notifications.map((n) => n.toJson()).toList(),
      );
      
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      final List<NotificationModel> notifications = await getNotifications();
      final int index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        
        final prefs = await SharedPreferences.getInstance();
        final String notificationsJson = json.encode(
          notifications.map((n) => n.toJson()).toList(),
        );
        
        await prefs.setString(_notificationsKey, notificationsJson);
      }
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Get unread count
  static Future<int> getUnreadCount() async {
    try {
      final List<NotificationModel> notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }
  
  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      // Handle error silently
    }
  }
}

