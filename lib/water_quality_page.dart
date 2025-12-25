import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';
import 'utils/ui_helpers.dart';



class WaterQualityPage extends StatefulWidget {
  const WaterQualityPage({super.key});

  @override
  State<WaterQualityPage> createState() => _WaterQualityPageState();
}

class _WaterQualityPageState extends State<WaterQualityPage> {
  String selectedState = 'All States';
  String selectedDistrict = 'All Districts';
  DateTimeRange? selectedDateRange;
  List<WaterQualityData> waterData = [];
  bool isLoading = true;

  final List<String> states = [
    'All States',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Gujarat'
  ];

  final List<String> districts = [
    'All Districts',
    'Mumbai',
    'Pune',
    'Bangalore',
    'Chennai'
  ];

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    setState(() => isLoading = true);
    
    try {
      // First test basic connection
      print('Testing API connection...');
      
      String endpoint = '/api/water';
      List<String> params = [];
      
      if (selectedState != 'All States') {
        params.add('state=$selectedState');
      }
      if (selectedDistrict != 'All Districts') {
        params.add('district=$selectedDistrict');
      }
      if (selectedDateRange != null) {
        params.add('start_date=${selectedDateRange!.start.toIso8601String()}');
        params.add('end_date=${selectedDateRange!.end.toIso8601String()}');
      }
      
      if (params.isNotEmpty) {
        endpoint += '?' + params.join('&');
      }
      
      print('Calling endpoint: $endpoint');
      final response = await ApiClient.getRequest(endpoint);
      print('Response received: ${response.length} items');
      
      setState(() {
        waterData = (response as List).map((item) => WaterQualityData(
          item['location'],
          item['ph'].toDouble(),
          item['turbidity'].toDouble(),
          item['contamination_level'],
          DateTime.parse(item['sample_date']),
        )).toList();
        isLoading = false;
      });
    } catch (e) {
      print('API Error: $e');
      // Fallback to mock data for testing
      setState(() {
        waterData = _getMockData();
        isLoading = false;
      });
      UIHelpers.showErrorSnackbar(context, 'Using mock data - Backend not available');
    }
  }
  
  List<WaterQualityData> _getMockData() {
    List<WaterQualityData> mockData = [
      WaterQualityData('Mumbai Central', 7.2, 2.1, 'Safe', DateTime(2024, 1, 15)),
      WaterQualityData('Pune Station', 6.8, 3.5, 'Moderate', DateTime(2024, 1, 14)),
      WaterQualityData('Bangalore Tech Park', 7.5, 1.8, 'Safe', DateTime(2024, 1, 13)),
      WaterQualityData('Chennai Marina', 6.5, 4.2, 'High Risk', DateTime(2024, 1, 12)),
    ];
    
    // Apply date filter to mock data
    if (selectedDateRange != null) {
      mockData = mockData.where((data) => 
        data.date.isAfter(selectedDateRange!.start.subtract(Duration(days: 1))) &&
        data.date.isBefore(selectedDateRange!.end.add(Duration(days: 1)))
      ).toList();
    }
    
    return mockData;
  }

  void _refreshData() {
    _loadWaterData();
    UIHelpers.showSuccessSnackbar(context, 'Data refreshed successfully!');
  }

  void _exportData() {
    final csvData = waterData.map((data) => {
          'Location': data.location,
          'pH': data.ph.toString(),
          'Turbidity': data.turbidity.toString(),
          'Contamination Level': data.contaminationLevel,
          'Date': '${data.date.day}/${data.date.month}/${data.date.year}',
        }).toList();

    UIHelpers.exportToCsv(csvData, 'water_quality_report');
    UIHelpers.showSuccessSnackbar(context, 'Report exported successfully!');
  }

  void _printReport() {
    final tableRows = waterData
        .map((data) =>
            '<tr><td>${data.location}</td><td>${data.ph}</td><td>${data.turbidity}</td><td>${data.contaminationLevel}</td><td>${data.date.day}/${data.date.month}/${data.date.year}</td></tr>')
        .join('');

    final content = '''
      <table>
        <tr><th>Location</th><th>pH</th><th>Turbidity</th><th>Contamination Level</th><th>Date</th></tr>
        $tableRows
      </table>
    ''';

    UIHelpers.printReport('Water Quality Report', content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Quality Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh'),
          IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportData,
              tooltip: 'Export CSV'),
          IconButton(
              icon: const Icon(Icons.print),
              onPressed: _printReport,
              tooltip: 'Print'),
        ],
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 800;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFilters(isMobile),
                      const SizedBox(height: 20),
                      _buildSummaryCards(isMobile),
                      const SizedBox(height: 20),
                      _buildChartsRow(isMobile),
                      const SizedBox(height: 20),
                      _buildDataTable(),
                    ],
                  ),
                );
              },
            ),


    );
  }

  // ---------------- FILTERS --------------------
  Widget _buildFilters(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isMobile
            ? Column(
                children: [
                  _stateDropdown(),
                  const SizedBox(height: 16),
                  _districtDropdown(),
                  const SizedBox(height: 16),
                  _datePickerField(),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _stateDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _districtDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _datePickerField()),
                ],
              ),
      ),
    );
  }

  DropdownButtonFormField<String> _stateDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedState,
      decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()),
      items: states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
      onChanged: (value) {
        setState(() => selectedState = value!);
        _loadWaterData();
      },
    );
  }

  DropdownButtonFormField<String> _districtDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDistrict,
      decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()),
      items: districts.map((district) => DropdownMenuItem(value: district, child: Text(district))).toList(),
      onChanged: (value) {
        setState(() => selectedDistrict = value!);
        _loadWaterData();
      },
    );
  }

  TextFormField _datePickerField() {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(labelText: 'Date Range', border: OutlineInputBorder()),
      controller: TextEditingController(
        text: selectedDateRange != null
            ? '${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}'
            : 'Select Range',
      ),
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024, 1, 1),
          lastDate: DateTime.now(),
        );
        if (range != null) {
          setState(() => selectedDateRange = range);
          _loadWaterData();
        }
      },
    );
  }

  // ---------------- SUMMARY CARDS --------------------
  Widget _buildSummaryCards(bool isMobile) {
    if (waterData.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No data available', style: TextStyle(fontSize: 16)),
        ),
      );
    }
    
    final avgPh = waterData.map((e) => e.ph).reduce((a, b) => a + b) / waterData.length;
    final avgTurbidity = waterData.map((e) => e.turbidity).reduce((a, b) => a + b) / waterData.length;
    final riskIndex = waterData.where((e) => e.contaminationLevel == 'High Risk').length / waterData.length;

    if (isMobile) {
      return Column(
        children: [
          _summaryCard('Average pH', avgPh.toStringAsFixed(1), Colors.blue),
          const SizedBox(height: 16),
          _summaryCard('Avg Turbidity', '${avgTurbidity.toStringAsFixed(1)} NTU', Colors.orange),
          const SizedBox(height: 16),
          _summaryCard('Risk Index', '${(riskIndex * 100).toStringAsFixed(0)}%', Colors.red),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _summaryCard('Average pH', avgPh.toStringAsFixed(1), Colors.blue)),
        const SizedBox(width: 16),
        Expanded(
            child: _summaryCard(
                'Avg Turbidity', '${avgTurbidity.toStringAsFixed(1)} NTU', Colors.orange)),
        const SizedBox(width: 16),
        Expanded(
            child:
                _summaryCard('Risk Index', '${(riskIndex * 100).toStringAsFixed(0)}%', Colors.red)),
      ],
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.analytics, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // ---------------- CHARTS --------------------
  Widget _buildChartsRow(bool isMobile) {
    final role = AuthService.currentRole;

    if (role == 'worker') {
      return _buildPhChart();
    }

    if (isMobile) {
      return Column(
        children: [
          _buildPhChart(),
          const SizedBox(height: 16),
          _buildTurbidityChart(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildPhChart()),
        const SizedBox(width: 16),
        Expanded(child: _buildTurbidityChart()),
      ],
    );
  }

  Widget _buildPhChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('pH Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: waterData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.ph))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTurbidityChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Turbidity Levels',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: waterData
                      .asMap()
                      .entries
                      .map(
                        (e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                                toY: e.value.turbidity,
                                color: Colors.orange,
                                width: 20)
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------- DATA TABLE --------------------
  Widget _buildDataTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Water Quality Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('pH')),
                  DataColumn(label: Text('Turbidity')),
                  DataColumn(label: Text('Risk Level')),
                  DataColumn(label: Text('Date')),
                ],
                rows: waterData
                    .map(
                      (data) => DataRow(
                        cells: [
                          DataCell(Text(data.location)),
                          DataCell(Text(data.ph.toString())),
                          DataCell(Text(data.turbidity.toString())),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    _getContaminationColor(data.contaminationLevel),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(data.contaminationLevel,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          DataCell(Text(
                              '${data.date.day}/${data.date.month}/${data.date.year}')),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ---------------- HELPERS --------------------
  Color _getContaminationColor(String level) {
    switch (level) {
      case 'Safe':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'High Risk':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class WaterQualityData {
  final String location;
  final double ph;
  final double turbidity;
  final String contaminationLevel;
  final DateTime date;

  WaterQualityData(
      this.location, this.ph, this.turbidity, this.contaminationLevel, this.date);
}
