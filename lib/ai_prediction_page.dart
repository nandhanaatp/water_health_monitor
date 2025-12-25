import 'package:flutter/material.dart';
import 'package:water_health_monitor/services/prediction_service.dart';

class AiPredictionPage extends StatefulWidget {
  const AiPredictionPage({super.key});

  @override
  State<AiPredictionPage> createState() => _AiPredictionPageState();
}

class _AiPredictionPageState extends State<AiPredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final _phController = TextEditingController();
  final _turbidityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _bacterialController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  PredictionResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Based Disease Risk Prediction'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildInputForm()),
                      const SizedBox(width: 20),
                      Expanded(flex: 3, child: _buildResultSection()),
                    ],
                  )
                : Column(
                    children: [
                      _buildInputForm(),
                      const SizedBox(height: 20),
                      _buildResultSection(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildInputForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Water Quality Parameters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField(_phController, 'pH Level', 'Enter pH (0-14)', TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_turbidityController, 'Turbidity (NTU)', 'Enter turbidity level',
                  TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(
                  _temperatureController, 'Temperature (°C)', 'Enter temperature', TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_bacterialController, 'Bacterial Count (CFU/ml)',
                  'Enter bacterial count', TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(
                  _locationController, 'Location', 'Enter location', TextInputType.text),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _predictRisk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Predict Risk',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint,
      TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        focusedBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
      ),
      validator: (value) =>
          value?.isEmpty == true ? 'This field is required' : null,
    );
  }

  Widget _buildResultSection() {
    if (_result == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 520,
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Enter parameters and click "Predict Risk"',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildRiskScoreCard(),
        const SizedBox(height: 20),
        _buildRecommendationsCard(),
      ],
    );
  }

  Widget _buildRiskScoreCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Risk Assessment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _result!.riskScore / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getRiskColor(_result!.riskCategory)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${_result!.riskScore}%',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(
                        _result!.riskCategory,
                        style: TextStyle(
                            fontSize: 16,
                            color: _getRiskColor(_result!.riskCategory)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getRiskColor(_result!.riskCategory).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRiskColor(_result!.riskCategory)),
              ),
              child: Text(
                'Risk Level: ${_result!.riskCategory}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(_result!.riskCategory)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recommendations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._result!.recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.teal, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(rec,
                            style: const TextStyle(fontSize: 14))),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // BACKEND CALL
  // -------------------------------------------------------------
  Future<void> _predictRisk() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ph = double.parse(_phController.text.trim());
      final turbidity = double.parse(_turbidityController.text.trim());
      final temperature = double.parse(_temperatureController.text.trim());
      final bacterialCount = int.parse(_bacterialController.text.trim());
      final location = _locationController.text.trim();

      final Map<String, dynamic> response = await PredictionService.predictRisk(
        ph: ph,
        turbidity: turbidity,
        temperature: temperature,
        bacterialCount: bacterialCount,
        location: location,
      );

      int scorePercent = 0;
      final raw = response['score'];

      if (raw is double) {
        scorePercent = raw <= 1.0 ? (raw * 100).round() : raw.round();
      } else if (raw is int) {
        scorePercent = raw;
      } else if (raw is String) {
        final v = double.tryParse(raw) ?? 0;
        scorePercent = v <= 1.0 ? (v * 100).round() : v.round();
      }

      final riskCategory = response['risk']?.toString() ?? 'Unknown';

      final recs = _getRecommendations(
          riskCategory, ph, turbidity, bacterialCount.toDouble());

      if (!mounted) return;

      setState(() {
        _result = PredictionResult(scorePercent, riskCategory, recs);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prediction failed: $e")),
      );
    }
  }

  List<String> _getRecommendations(
      String category, double ph, double turbidity, double bacterial) {
    List<String> recs = [];

    if (category.toLowerCase() == 'high') {
      recs.addAll([
        'Immediate community alert recommended',
        'Boil water for at least 5 minutes',
        'Increase chlorination and disinfect systems',
        'Inspect water source urgently',
      ]);
    } else if (category.toLowerCase() == 'medium') {
      recs.addAll([
        'Boil water before use',
        'Monitor water quality daily',
        'Alternative water sources recommended'
      ]);
    } else {
      recs.addAll([
        'Water appears safe',
        'Continue routine monitoring',
        'Maintain treatment systems'
      ]);
    }

    if (ph < 6.5 || ph > 8.5) recs.add('Correct pH to recommended range 6.5–8.5');
    if (turbidity > 2) recs.add('Improve filtration');
    if (bacterial > 100) recs.add('Increase disinfection');

    return recs;
  }

  Color _getRiskColor(String category) {
    switch (category.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _phController.dispose();
    _turbidityController.dispose();
    _temperatureController.dispose();
    _bacterialController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

class PredictionResult {
  final int riskScore;
  final String riskCategory;
  final List<String> recommendations;

  PredictionResult(this.riskScore, this.riskCategory, this.recommendations);
}
