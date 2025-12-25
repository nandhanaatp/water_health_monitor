import 'package:flutter/material.dart';
import 'services/notification_service.dart';

class QuickTestPage extends StatefulWidget {
  @override
  _QuickTestPageState createState() => _QuickTestPageState();
}

class _QuickTestPageState extends State<QuickTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Notification Test'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Generate Test Notifications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.addLocalNotification(
                  'Critical Water Alert',
                  'pH level 5.2 detected at Test Location A - Immediate action required',
                  'water'
                );
                _showSuccess('Water alert added');
              },
              icon: Icon(Icons.water_drop),
              label: Text('Add Water Quality Alert'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.addLocalNotification(
                  'Disease Outbreak Alert',
                  '25 cases of Cholera reported in Test District - Health advisory issued',
                  'disease'
                );
                _showSuccess('Disease alert added');
              },
              icon: Icon(Icons.health_and_safety),
              label: Text('Add Disease Alert'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.addLocalNotification(
                  'System Maintenance',
                  'Scheduled maintenance tonight from 2-4 AM. System may be unavailable.',
                  'system'
                );
                _showSuccess('System alert added');
              },
              icon: Icon(Icons.settings),
              label: Text('Add System Alert'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.addLocalNotification(
                  'High Turbidity Warning',
                  'Turbidity level 6.8 NTU detected at Test Location B - Water treatment needed',
                  'water'
                );
                _showSuccess('Turbidity alert added');
              },
              icon: Icon(Icons.blur_on),
              label: Text('Add Turbidity Alert'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            ),
            
            SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: () {
                // Add multiple notifications at once
                NotificationService.addLocalNotification(
                  'Contamination Alert',
                  'High risk contamination detected at Test Location C',
                  'water'
                );
                NotificationService.addLocalNotification(
                  'Health Advisory',
                  'Increased disease activity in your region - Take precautions',
                  'disease'
                );
                NotificationService.addLocalNotification(
                  'Data Backup Complete',
                  'Daily data backup completed successfully',
                  'system'
                );
                _showSuccess('3 notifications added');
              },
              icon: Icon(Icons.add_alert),
              label: Text('Add Multiple Alerts'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
            
            SizedBox(height: 20),
            
            Text(
              'Current Notifications: ${NotificationService.notifications.length}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              'Unread: ${NotificationService.unreadCount}',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            
            SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to notifications page
                Navigator.pushNamed(context, '/notifications');
              },
              icon: Icon(Icons.notifications),
              label: Text('View Notifications'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
    setState(() {}); // Refresh the count display
  }
}