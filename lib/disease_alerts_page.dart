import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'utils/ui_helpers.dart';



class DiseaseAlertsPage extends StatefulWidget {
  const DiseaseAlertsPage({super.key});

  @override
  State<DiseaseAlertsPage> createState() => _DiseaseAlertsPageState();
}

class _DiseaseAlertsPageState extends State<DiseaseAlertsPage> {
  String searchQuery = '';
  String selectedDisease = 'All Diseases';
  String selectedDistrict = 'All Districts';

  final List<String> diseases = [
    'All Diseases',
    'Dengue',
    'Malaria',
    'Typhoid',
    'Cholera',
    'COVID-19'
  ];

  final List<String> districts = [
    'All Districts',
    'Mumbai',
    'Pune',
    'Bangalore',
    'Chennai',
    'Delhi'
  ];

  final List<DiseaseAlert> mockAlerts = [
    DiseaseAlert('Dengue', 45, 'High', 'Mumbai Central', DateTime(2024, 1, 15)),
    DiseaseAlert('Malaria', 23, 'Medium', 'Pune Station', DateTime(2024, 1, 14)),
    DiseaseAlert('COVID-19', 12, 'Low', 'Bangalore Tech Park', DateTime(2024, 1, 13)),
    DiseaseAlert('Typhoid', 67, 'High', 'Chennai Marina', DateTime(2024, 1, 12)),
    DiseaseAlert('Cholera', 8, 'Low', 'Delhi Center', DateTime(2024, 1, 11)),
    DiseaseAlert('Dengue', 34, 'Medium', 'Mumbai Suburbs', DateTime(2024, 1, 10)),
    DiseaseAlert('Malaria', 89, 'High', 'Pune Industrial', DateTime(2024, 1, 9)),
    DiseaseAlert('COVID-19', 15, 'Low', 'Bangalore Lake', DateTime(2024, 1, 8)),
  ];

  final Map<String, int> regionCases = {
    'Mumbai': 79,
    'Pune': 112,
    'Bangalore': 27,
    'Chennai': 67,
    'Delhi': 8,
    'Kolkata': 45,
    'Hyderabad': 33,
    'Ahmedabad': 21,
  };

  List<DiseaseAlert> get filteredAlerts {
    return mockAlerts.where((alert) {
      final matchesSearch =
          alert.diseaseName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              alert.location.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesDisease =
          selectedDisease == 'All Diseases' || alert.diseaseName == selectedDisease;

      final matchesDistrict = selectedDistrict == 'All Districts' ||
          alert.location.contains(selectedDistrict);

      return matchesSearch && matchesDisease && matchesDistrict;
    }).toList();
  }

  void _refreshData() {
    setState(() {});
    UIHelpers.showSuccessSnackbar(context, 'Alerts refreshed successfully!');
  }

  void _exportData() {
    final csvData = filteredAlerts.map((alert) {
      return {
        'Disease': alert.diseaseName,
        'Cases': alert.cases,
        'Risk Level': alert.riskLevel,
        'Location': alert.location,
        'Date':
            '${alert.date.day}/${alert.date.month}/${alert.date.year}'
      };
    }).toList();

    UIHelpers.exportToCsv(csvData, 'disease_alerts_report');
    UIHelpers.showSuccessSnackbar(context, 'Exported Successfully');
  }

  void _printReport() {
    final tableRows = filteredAlerts.map((alert) {
      return '<tr>'
          '<td>${alert.diseaseName}</td>'
          '<td>${alert.cases}</td>'
          '<td>${alert.riskLevel}</td>'
          '<td>${alert.location}</td>'
          '<td>${alert.date.day}/${alert.date.month}/${alert.date.year}</td>'
          '</tr>';
    }).join('');

    final html = '''
      <table>
        <tr>
          <th>Disease</th><th>Cases</th><th>Risk</th><th>Location</th><th>Date</th>
        </tr>
        $tableRows
      </table>
    ''';

    UIHelpers.printReport('Disease Alerts Report', html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Alerts'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportData),
          IconButton(icon: const Icon(Icons.print), onPressed: _printReport),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchAndFilters(isMobile),
                const SizedBox(height: 20),
                _buildHeatmap(isMobile),
                const SizedBox(height: 20),
                Expanded(child: _buildAlertsList()),
              ],
            ),
          );
        },
      ),


    );
  }

  // ---------------------------------------------------------
  // SEARCH + FILTERS
  // ---------------------------------------------------------
  Widget _buildSearchAndFilters(bool isMobile) {
    final role = AuthService.currentRole;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Alerts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
            const SizedBox(height: 16),

            isMobile
                ? Column(
                    children: [
                      _diseaseDropdown(),
                      const SizedBox(height: 16),
                      _districtDropdown(role),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _diseaseDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _districtDropdown(role)),
                    ],
                  ),

            if (role == 'worker')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Workers can only view alerts.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DropdownButtonFormField<String> _diseaseDropdown() {
    return DropdownButtonFormField(
      value: selectedDisease,
      decoration: const InputDecoration(
          labelText: 'Disease', border: OutlineInputBorder()),
      items: diseases.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (v) => setState(() => selectedDisease = v!),
    );
  }

  DropdownButtonFormField<String> _districtDropdown(String? role) {
    return DropdownButtonFormField(
      value: selectedDistrict,
      decoration: const InputDecoration(
          labelText: 'District', border: OutlineInputBorder()),
      items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged:
          role == 'worker' ? null : (v) => setState(() => selectedDistrict = v!),
    );
  }

  // ---------------------------------------------------------
  // HEATMAP
  // ---------------------------------------------------------
  Widget _buildHeatmap(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Cases by Region',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            isMobile
                ? Column(
                    children: regionCases.entries
                        .map((entry) =>
                            _buildHeatmapTile(entry.key, entry.value))
                        .toList(),
                  )
                : Wrap(
                    spacing: 8,
                    children: regionCases.entries
                        .map((entry) =>
                            _buildHeatmapTile(entry.key, entry.value))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapTile(String region, int cases) {
    Color color;
    if (cases > 80) {
      color = Colors.red;
    } else if (cases > 40) {
      color = Colors.orange;
    } else if (cases > 20) {
      color = Colors.yellow.shade700;
    } else {
      color = Colors.green;
    }

    return Container(
      width: 120,
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(region,
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('$cases cases',
              style: const TextStyle(color: Colors.white, fontSize: 12))
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // ALERTS LIST
  // ---------------------------------------------------------
  Widget _buildAlertsList() {
    final alerts = filteredAlerts;

    if (alerts.isEmpty) {
      return const Center(child: Text('No alerts found.'));
    }

    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, i) {
        final alert = alerts[i];

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getRiskColor(alert.riskLevel),
              child: Text(alert.cases.toString(),
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(alert.diseaseName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text(
                'Location: ${alert.location}\nDate: ${alert.date.day}/${alert.date.month}/${alert.date.year}'),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: _getRiskColor(alert.riskLevel),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(alert.riskLevel,
                  style:
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }



  // ---------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------
  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class DiseaseAlert {
  final String diseaseName;
  final int cases;
  final String riskLevel;
  final String location;
  final DateTime date;

  DiseaseAlert(
      this.diseaseName, this.cases, this.riskLevel, this.location, this.date);
}
