import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RegionalReportsPage extends StatefulWidget {
  const RegionalReportsPage({super.key});

  @override
  State<RegionalReportsPage> createState() => _RegionalReportsPageState();
}

class _RegionalReportsPageState extends State<RegionalReportsPage> {
  String selectedState = 'Maharashtra';
  String selectedDistrict = 'Mumbai';

  final Map<String, List<String>> stateDistricts = {
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
  };

  final Map<String, RegionalData> mockData = {
    'Mumbai': RegionalData(145, 'Poor', [12, 15, 18, 14, 16, 19, 22]),
    'Pune': RegionalData(89, 'Fair', [8, 10, 12, 9, 11, 13, 15]),
    'Nagpur': RegionalData(67, 'Good', [5, 7, 6, 8, 7, 9, 10]),
    'Nashik': RegionalData(34, 'Good', [3, 4, 5, 3, 4, 6, 7]),
    'Bangalore': RegionalData(78, 'Fair', [6, 8, 9, 7, 8, 10, 12]),
    'Mysore': RegionalData(23, 'Good', [2, 3, 2, 4, 3, 4, 5]),
    'Chennai': RegionalData(156, 'Poor', [14, 16, 18, 15, 17, 20, 23]),
    'Coimbatore': RegionalData(45, 'Good', [4, 5, 6, 4, 5, 7, 8]),
    'Ahmedabad': RegionalData(98, 'Fair', [9, 11, 10, 12, 11, 13, 15]),
    'Surat': RegionalData(67, 'Fair', [6, 7, 8, 6, 7, 9, 10]),
  };

  List<String> get availableDistricts => stateDistricts[selectedState] ?? [];
  RegionalData get currentData =>
      mockData[selectedDistrict] ?? RegionalData(0, 'Unknown', []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regional Health Reports'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFilters(),
                const SizedBox(height: 20),

                // Responsive Layout Fix ↓↓↓
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildMapSection()),
                          const SizedBox(width: 20),
                          Expanded(flex: 3, child: _buildDataSection()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildMapSection(),
                          const SizedBox(height: 20),
                          _buildDataSection(),
                        ],
                      ),
                // Responsive Layout Fix ↑↑↑

                const SizedBox(height: 20),
                _buildRiskAreasGrid(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                value: selectedState,
                decoration: const InputDecoration(
                    labelText: 'State', border: OutlineInputBorder()),
                items: stateDistricts.keys
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value!;
                    selectedDistrict = availableDistricts.first;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField(
                value: selectedDistrict,
                decoration: const InputDecoration(
                    labelText: 'District', border: OutlineInputBorder()),
                items: availableDistricts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setState(() => selectedDistrict = value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Regional Map View',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('$selectedState Map',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  ...availableDistricts
                      .asMap()
                      .entries
                      .map((e) => _buildMapMarker(e.key, e.value)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMarker(int index, String district) {
    final data = mockData[district];
    if (data == null) return const SizedBox();

    final positions = [
      const Offset(0.3, 0.4),
      const Offset(0.6, 0.3),
      const Offset(0.7, 0.6),
      const Offset(0.4, 0.7)
    ];

    final pos = positions[index % positions.length];

    return Positioned(
      left: pos.dx * 250,
      top: pos.dy * 200,
      child: GestureDetector(
        onTap: () => setState(() => selectedDistrict = district),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(data.waterQualityStatus),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(district,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Column(
      children: [
        _buildStatsCards(),
        const SizedBox(height: 20),
        _buildTrendChart(),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Waterborne Cases',
                '${currentData.waterborneCases}', Icons.local_hospital, Colors.red)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('Water Quality', currentData.waterQualityStatus,
                Icons.water_drop, _getStatusColor(currentData.waterQualityStatus))),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value,
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('7-Day Trend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ];
                            return Text(days[value.toInt() % 7]);
                          }),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: currentData.trendData
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData:
                          BarAreaData(show: true, color: Colors.teal.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAreasGrid() {
    final high = mockData.entries.where((e) => e.value.waterborneCases > 100);
    final med =
        mockData.entries.where((e) => e.value.waterborneCases >= 50 && e.value.waterborneCases <= 100);
    final low = mockData.entries.where((e) => e.value.waterborneCases < 50);

    return Row(
      children: [
        Expanded(child: _buildRiskCard('High Risk Areas', high, Colors.red)),
        const SizedBox(width: 16),
        Expanded(child: _buildRiskCard('Medium Risk Areas', med, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildRiskCard('Low Risk Areas', low, Colors.green)),
      ],
    );
  }

  Widget _buildRiskCard(
      String title, Iterable<MapEntry<String, RegionalData>> areas, Color color) {
    final list = areas.toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: color),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),

            Text('${list.length} areas',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 12),

            ...list.take(3).map((e) =>
                Text('• ${e.key} (${e.value.waterborneCases} cases)')),

            if (list.length > 3)
              Text('... and ${list.length - 3} more',
                  style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String s) {
    switch (s) {
      case 'Good':
        return Colors.green;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class RegionalData {
  final int waterborneCases;
  final String waterQualityStatus;
  final List<int> trendData;

  RegionalData(this.waterborneCases, this.waterQualityStatus, this.trendData);
}
