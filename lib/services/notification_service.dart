import 'dart:convert';
import 'api_client.dart';

class NotificationService {
  static List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Welcome to Health Monitor',
      'message': 'Your community health monitoring system is now active',
      'type': 'system',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      'read': false,
    },
    {
      'id': 2,
      'title': 'Sample Water Alert',
      'message': 'This is a sample notification - use Quick Test to add more',
      'type': 'water',
      'timestamp': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
      'read': false,
    },
  ];
  
  static List<Map<String, dynamic>> get notifications => _notifications;
  static int get unreadCount => _notifications.where((n) => !n['read']).length;

  // Get all notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await ApiClient.getRequest('/api/notifications');
      _notifications = List<Map<String, dynamic>>.from(response['notifications']);
      return _notifications;
    } catch (e) {
      return _notifications;
    }
  }

  // Mark notification as read
  static void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['read'] = true;
    }
  }

  // Add local notification (for demo purposes)
  static void addLocalNotification(String title, String message, String type) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'message': message,
      'type': type, // 'water', 'disease', 'system'
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });
  }

  // Check for critical alerts
  static void checkCriticalAlerts(Map<String, dynamic> waterData) {
    final ph = waterData['ph'] ?? 7.0;
    final turbidity = waterData['turbidity'] ?? 0.0;
    final contamination = waterData['contamination_level'] ?? 'Safe';

    if (ph < 6.0 || ph > 8.5) {
      addLocalNotification(
        'Critical pH Level',
        'pH level ${ph.toStringAsFixed(1)} detected at ${waterData['location']}',
        'water'
      );
    }

    if (turbidity > 5.0) {
      addLocalNotification(
        'High Turbidity Alert',
        'Turbidity ${turbidity.toStringAsFixed(1)} NTU at ${waterData['location']}',
        'water'
      );
    }

    if (contamination == 'High Risk') {
      addLocalNotification(
        'Contamination Alert',
        'High risk contamination detected at ${waterData['location']}',
        'water'
      );
    }
  }
}