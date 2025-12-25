import 'package:flutter/material.dart';

import 'water_quality_page.dart';
import 'disease_alerts_page.dart';
import 'ai_prediction_page.dart';
import 'regional_reports_page.dart';
import 'login_page.dart';
import 'change_password_page.dart';
import 'notifications_page.dart';
import 'test_notifications_page.dart';
import 'quick_test_page.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';



void main() {
  runApp(const WaterHealthMonitorApp());
}

class WaterHealthMonitorApp extends StatelessWidget {
  const WaterHealthMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Community Health Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: AuthService.isLoggedIn ? const DashboardPage() : const LoginPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Community Health Monitoring'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          // Notifications icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage()),
                  );
                },
              ),
              if (NotificationService.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${NotificationService.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('${AuthService.currentUser} (${AuthService.currentRole})'),
                enabled: false,
              ),
              const PopupMenuItem(
                value: 'change_password',
                child: Text('Change Password'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                AuthService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                );
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: constraints.maxWidth > 800 ? 1.0 : 2.0,
              children: _getAvailableCards(),
            );
          },
        ),
      ),


    );
  }

  List<Widget> _getAvailableCards() {
    final role = AuthService.currentRole;
    List<Widget> cards = [];

    // Water Quality - Available to all
    cards.add(_buildCard(Icons.water_drop, 'Water Quality', 'Check latest water data'));

    // Disease Alerts - Available to all
    cards.add(_buildCard(Icons.health_and_safety, 'Disease Alerts', 'Recent health reports'));

    // Notifications - Available to all
    cards.add(_buildCard(Icons.notifications, 'Notifications', 'System alerts and updates'));

    // Test Notifications - Available to all for quick testing
    cards.add(_buildCard(Icons.bug_report, 'Quick Test', 'Generate test notifications'));
    
    // Advanced Test - Only for admin
    if (role == 'admin') {
      cards.add(_buildCard(Icons.science, 'Advanced Test', 'Backend API testing'));
    }

    // AI Prediction - Only officer/admin
    if (role == 'officer' || role == 'admin') {
      cards.add(_buildCard(Icons.analytics, 'AI Prediction', 'Risk prediction dashboard'));
    }

    // Regional Reports - Only Admin
    if (role == 'admin') {
      cards.add(_buildCard(Icons.map, 'Regional Reports', 'Region-wise statistics'));
    }

    return cards;
  }

  Widget _buildCard(IconData icon, String title, String subtitle) {
    int alertCount = _getAlertCount(title);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (title == 'Water Quality') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const WaterQualityPage()));
          } else if (title == 'Disease Alerts') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DiseaseAlertsPage()));
          } else if (title == 'AI Prediction') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AiPredictionPage()));
          } else if (title == 'Regional Reports') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegionalReportsPage()));
          } else if (title == 'Notifications') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NotificationsPage()));
          } else if (title == 'Quick Test') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => QuickTestPage()));
          } else if (title == 'Advanced Test') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TestNotificationsPage()));
          }
        },
        borderRadius: BorderRadius.circular(16),

        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: Colors.teal),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            if (alertCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    alertCount.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _getAlertCount(String title) {
    switch (title) {
      case 'Water Quality':
        return 3;
      case 'Disease Alerts':
        return 7;
      case 'AI Prediction':
        return 2;
      case 'Regional Reports':
        return 1;
      default:
        return 0;
    }
  }


}
