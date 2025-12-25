import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'services/api_client.dart';

class TestNotificationsPage extends StatefulWidget {
  @override
  _TestNotificationsPageState createState() => _TestNotificationsPageState();
}

class _TestNotificationsPageState extends State<TestNotificationsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Notifications'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Notification Triggers',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            _buildTestCard(
              'Critical pH Water Sample',
              'Submit water sample with pH 5.2 (triggers alert)',
              Icons.water_drop,
              Colors.red,
              () => _testCriticalPH(),
            ),
            
            _buildTestCard(
              'High Turbidity Sample',
              'Submit water sample with turbidity 6.8 NTU',
              Icons.blur_on,
              Colors.orange,
              () => _testHighTurbidity(),
            ),
            
            _buildTestCard(
              'High Risk Contamination',
              'Submit contaminated water sample',
              Icons.warning,
              Colors.red[700]!,
              () => _testContamination(),
            ),
            
            _buildTestCard(
              'Disease Outbreak Alert',
              'Report critical disease outbreak',
              Icons.health_and_safety,
              Colors.purple,
              () => _testDiseaseOutbreak(),
            ),
            
            _buildTestCard(
              'Generate Test Notifications',
              'Add sample notifications for testing',
              Icons.notifications_active,
              Colors.blue,
              () => _generateTestNotifications(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: _isLoading ? CircularProgressIndicator() : Icon(Icons.play_arrow),
        onTap: _isLoading ? null : onTap,
      ),
    );
  }

  Future<void> _testCriticalPH() async {
    setState(() => _isLoading = true);
    
    try {
      await ApiClient.postRequest('/api/water', {
        'location': 'Test Location - Critical pH',
        'state': 'Test State',
        'district': 'Test District',
        'ph': 5.2,  // Critical - will trigger alert
        'turbidity': 2.0,
        'bacterial_count': 100,
        'temperature': 25.0,
        'contamination_level': 'Safe'
      });
      
      // Simulate notification check
      NotificationService.checkCriticalAlerts({
        'ph': 5.2,
        'location': 'Test Location - Critical pH'
      });
      
      _showSuccess('Critical pH sample submitted - Alert generated!');
      setState(() {});
      
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testHighTurbidity() async {
    setState(() => _isLoading = true);
    
    try {
      await ApiClient.postRequest('/api/water', {
        'location': 'Test Location - High Turbidity',
        'state': 'Test State',
        'district': 'Test District',
        'ph': 7.2,
        'turbidity': 6.8,  // High - will trigger alert
        'bacterial_count': 200,
        'temperature': 26.0,
        'contamination_level': 'Moderate'
      });
      
      NotificationService.checkCriticalAlerts({
        'turbidity': 6.8,
        'location': 'Test Location - High Turbidity'
      });
      
      _showSuccess('High turbidity sample submitted - Alert generated!');
      setState(() {});
      
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testContamination() async {
    setState(() => _isLoading = true);
    
    try {
      await ApiClient.postRequest('/api/water', {
        'location': 'Test Location - Contaminated',
        'state': 'Test State',
        'district': 'Test District',
        'ph': 7.0,
        'turbidity': 3.0,
        'bacterial_count': 500,
        'temperature': 28.0,
        'contamination_level': 'High Risk'  // Will trigger alert
      });
      
      NotificationService.checkCriticalAlerts({
        'contamination_level': 'High Risk',
        'location': 'Test Location - Contaminated'
      });
      
      _showSuccess('Contaminated sample submitted - Alert generated!');
      setState(() {});
      
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testDiseaseOutbreak() async {
    setState(() => _isLoading = true);
    
    try {
      await ApiClient.postRequest('/api/alerts', {
        'disease': 'Test Disease Outbreak',
        'cases': 25,
        'risk_level': 'Critical',
        'location': 'Test Area - Disease',
        'state': 'Test State',
        'district': 'Test District'
      });
      
      NotificationService.addLocalNotification(
        'Disease Outbreak Alert',
        '25 cases of Test Disease Outbreak reported in Test Area - Disease',
        'disease'
      );
      
      _showSuccess('Disease outbreak reported - Alert generated!');
      setState(() {});
      
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateTestNotifications() {
    // Add various test notifications
    NotificationService.addLocalNotification(
      'System Update',
      'New features have been added to the monitoring system',
      'system'
    );
    
    NotificationService.addLocalNotification(
      'Water Quality Alert',
      'Unusual pH levels detected in multiple locations',
      'water'
    );
    
    NotificationService.addLocalNotification(
      'Health Advisory',
      'Increased disease activity reported in your region',
      'disease'
    );
    
    NotificationService.addLocalNotification(
      'Maintenance Notice',
      'Scheduled system maintenance tonight 2-4 AM',
      'system'
    );
    
    _showSuccess('4 test notifications generated!');
    setState(() {});
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}