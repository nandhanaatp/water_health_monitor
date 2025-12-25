import 'package:flutter/material.dart';
import 'services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      // Load from backend first
      await NotificationService.getNotifications();
      setState(() {
        notifications = NotificationService.notifications;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      // Fallback to local notifications
      setState(() {
        notifications = NotificationService.notifications;
      });
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'water': return Icons.water_drop;
      case 'disease': return Icons.health_and_safety;
      case 'system': return Icons.settings;
      default: return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'water': return Colors.blue;
      case 'disease': return Colors.red;
      case 'system': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in notifications) {
                    notification['read'] = true;
                  }
                });
              },
              child: Text('Mark All Read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    child: Text('Refresh'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['read'] ?? false;
                
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getNotificationColor(notification['type']),
                      child: Icon(_getNotificationIcon(notification['type']), color: Colors.white),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message']),
                        SizedBox(height: 4),
                        Text(
                          _formatTimestamp(notification['timestamp']),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: isRead ? null : Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: () {
                      if (!isRead) {
                        setState(() {
                          NotificationService.markAsRead(notification['id']);
                          notification['read'] = true;
                        });
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}