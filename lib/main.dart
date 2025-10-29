import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      home: const BMICalculatorScreen(),
    );
  }
}

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({Key? key}) : super(key: key);

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();

  String _selectedHeightUnit = 'cm';
  String _selectedWeightUnit = 'kg';

  String _heightConversion = '';
  String _weightConversion = '';

  double? _bmi;
  String _bmiCategory = '';
  double? _extraWeight;
  double? _targetWeight;
  double? _heightInMeters;
  double? _weightInKg;

  final List<String> _heightUnits = ['cm', 'm', 'inches', 'feet', 'ft+in'];
  final List<String> _weightUnits = ['kg', 'lbs'];

  @override
  void initState() {
    super.initState();

    // Add listeners for real-time conversion display
    _heightController.addListener(_updateHeightConversion);
    _weightController.addListener(_updateWeightConversion);
    _feetController.addListener(_updateHeightConversion);
    _inchesController.addListener(_updateHeightConversion);
  }

  void _updateHeightConversion() {
    setState(() {
      if (_selectedHeightUnit == 'ft+in') {
        final feet = double.tryParse(_feetController.text.trim());
        final inches = double.tryParse(_inchesController.text.trim());
        if (feet != null && inches != null && feet >= 0 && inches >= 0 && inches < 12) {
          final totalInches = (feet * 12) + inches;
          final meters = totalInches * 0.0254;
          _heightConversion = '≈ ${meters.toStringAsFixed(2)} m';
        } else if (feet != null && feet >= 0) {
          final meters = feet * 0.3048;
          _heightConversion = '≈ ${meters.toStringAsFixed(2)} m';
        } else {
          _heightConversion = '';
        }
      } else {
        final height = double.tryParse(_heightController.text.trim());
        if (height != null && height > 0) {
          final meters = _convertHeightToMeters(height, _selectedHeightUnit);
          if (_selectedHeightUnit != 'm') {
            _heightConversion = '≈ ${meters.toStringAsFixed(2)} m';
          } else {
            _heightConversion = '';
          }
        } else {
          _heightConversion = '';
        }
      }
    });
  }

  void _updateWeightConversion() {
    setState(() {
      final weight = double.tryParse(_weightController.text.trim());
      if (weight != null && weight > 0) {
        final kg = _convertWeightToKg(weight, _selectedWeightUnit);
        if (_selectedWeightUnit != 'kg') {
          _weightConversion = '≈ ${kg.toStringAsFixed(1)} kg';
        } else {
          _weightConversion = '';
        }
      } else {
        _weightConversion = '';
      }
    });
  }

  @override
  void dispose() {
    _heightController.removeListener(_updateHeightConversion);
    _weightController.removeListener(_updateWeightConversion);
    _feetController.removeListener(_updateHeightConversion);
    _inchesController.removeListener(_updateHeightConversion);
    _heightController.dispose();
    _weightController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    super.dispose();
  }

  // Convert height to meters
  double _convertHeightToMeters(double height, String unit) {
    switch (unit) {
      case 'cm':
        return height / 100;
      case 'm':
        return height;
      case 'inches':
        return height * 0.0254;
      case 'feet':
        return height * 0.3048;
      default:
        return height;
    }
  }

  // Convert weight to kilograms
  double _convertWeightToKg(double weight, String unit) {
    switch (unit) {
      case 'kg':
        return weight;
      case 'lbs':
        return weight * 0.453592;
      default:
        return weight;
    }
  }

  // Get BMI category
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Get category color
  Color _getCategoryColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi >= 18.5 && bmi < 25) {
      return Colors.green;
    } else if (bmi >= 25 && bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _calculateBMI() {
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();
    final feetText = _feetController.text.trim();
    final inchesText = _inchesController.text.trim();

    // Check if using ft+in mode
    if (_selectedHeightUnit == 'ft+in') {
      if (feetText.isEmpty || inchesText.isEmpty || weightText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter feet, inches, and weight'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final feet = double.tryParse(feetText);
      final inches = double.tryParse(inchesText);
      final weight = double.tryParse(weightText);

      if (feet == null || inches == null || weight == null ||
          feet < 0 || inches < 0 || weight <= 0 || inches >= 12) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid values (inches must be 0-11)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Convert feet + inches to total inches, then to meters
      final totalInches = (feet * 12) + inches;
      final heightInMeters = totalInches * 0.0254;
      final weightInKg = _convertWeightToKg(weight, _selectedWeightUnit);

      // Calculate BMI
      final bmi = weightInKg / (heightInMeters * heightInMeters);

      // Calculate target weight for BMI 23
      final targetBMI = 23.0;
      final targetWeight = targetBMI * (heightInMeters * heightInMeters);

      // Calculate extra weight
      final extraWeight = weightInKg - targetWeight;

      setState(() {
        _bmi = bmi;
        _bmiCategory = _getBMICategory(bmi);
        _extraWeight = extraWeight;
        _targetWeight = targetWeight;
        _heightInMeters = heightInMeters;
        _weightInKg = weightInKg;
      });
      return;
    }

    // Original logic for other height units
    if (heightText.isEmpty || weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both height and weight'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid positive numbers'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert to standard units
    final heightInMeters = _convertHeightToMeters(height, _selectedHeightUnit);
    final weightInKg = _convertWeightToKg(weight, _selectedWeightUnit);

    // Calculate BMI
    final bmi = weightInKg / (heightInMeters * heightInMeters);

    // Calculate target weight for BMI 23
    final targetBMI = 23.0;
    final targetWeight = targetBMI * (heightInMeters * heightInMeters);

    // Calculate extra weight
    final extraWeight = weightInKg - targetWeight;

    setState(() {
      _bmi = bmi;
      _bmiCategory = _getBMICategory(bmi);
      _extraWeight = extraWeight;
      _targetWeight = targetWeight;
      _heightInMeters = heightInMeters;
      _weightInKg = weightInKg;
    });
  }

  void _reset() {
    setState(() {
      _heightController.clear();
      _weightController.clear();
      _feetController.clear();
      _inchesController.clear();
      _bmi = null;
      _bmiCategory = '';
      _extraWeight = null;
      _targetWeight = null;
      _heightInMeters = null;
      _weightInKg = null;
      _heightConversion = '';
      _weightConversion = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 40.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Height Input Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Height',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _selectedHeightUnit,
                            underline: Container(),
                            items: _heightUnits.map((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(
                                  unit,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedHeightUnit = newValue!;
                                _updateHeightConversion();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Show different input based on selected unit
                      if (_selectedHeightUnit == 'ft+in')
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _feetController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                decoration: InputDecoration(
                                  labelText: 'Feet',
                                  hintText: '5',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _inchesController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Inches',
                                  hintText: '7',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        TextField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Enter height',
                            suffixText: _selectedHeightUnit,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      // Real-time conversion display
                      if (_heightConversion.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _heightConversion,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Weight Input Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weight',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _selectedWeightUnit,
                            underline: Container(),
                            items: _weightUnits.map((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(
                                  unit,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedWeightUnit = newValue!;
                                _updateWeightConversion();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Enter weight',
                          suffixText: _selectedWeightUnit,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      ),
                      // Real-time conversion display
                      if (_weightConversion.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _weightConversion,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Calculate Button
              ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Calculate BMI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Reset Button
              OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: const BorderSide(color: Colors.blue, width: 2),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Results Card with Gauge
              if (_bmi != null)
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor(_bmi!).withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // BMI Gauge
                        BMIGauge(bmi: _bmi!),
                        const SizedBox(height: 16),

                        // Conversion Display
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.straighten, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Height: ${_heightInMeters!.toStringAsFixed(2)} m',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.monitor_weight, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Weight: ${_weightInKg!.toStringAsFixed(1)} kg',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // BMI Value and Category
                        Text(
                          _bmi!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(_bmi!),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getCategoryColor(_bmi!).withOpacity(0.7),
                                _getCategoryColor(_bmi!),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: _getCategoryColor(_bmi!).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _bmiCategory,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Divider(thickness: 1),
                        const SizedBox(height: 20),

                        // Target Weight Information
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.flag, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Target Weight (BMI 23)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_targetWeight!.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Weight Comparison
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _extraWeight! > 0
                                  ? [const Color(0xFFFF6F00), const Color(0xFFE65100)]
                                  : [const Color(0xFF43A047), const Color(0xFF2E7D32)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: (_extraWeight! > 0 ? Colors.orange : Colors.green).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _extraWeight! > 0
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _extraWeight! > 0
                                          ? 'Extra Weight'
                                          : 'Below Target',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_extraWeight! > 0 ? '+' : ''}${_extraWeight!.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _extraWeight! > 0
                                    ? 'Above target for BMI 23'
                                    : 'Below target for BMI 23',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom BMI Gauge Widget
class BMIGauge extends StatelessWidget {
  final double bmi;

  const BMIGauge({Key? key, required this.bmi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: CustomPaint(
        painter: BMIGaugePainter(bmi: bmi),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'BMI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BMIGaugePainter extends CustomPainter {
  final double bmi;

  BMIGaugePainter({required this.bmi});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final strokeWidth = 25.0;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Define BMI segments with colors
    final segments = [
      {'start': 0.0, 'end': 18.5, 'color': Colors.blue},
      {'start': 18.5, 'end': 25.0, 'color': Colors.green},
      {'start': 25.0, 'end': 30.0, 'color': Colors.orange},
      {'start': 30.0, 'end': 40.0, 'color': Colors.red},
    ];

    // Draw colored segments
    for (var segment in segments) {
      final startBMI = segment['start'] as double;
      final endBMI = segment['end'] as double;
      final color = segment['color'] as Color;

      final startAngle = _bmiToAngle(startBMI);
      final sweepAngle = _bmiToAngle(endBMI) - startAngle;

      final segmentPaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.6), color],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        segmentPaint,
      );
    }

    // Draw needle
    final needleAngle = _bmiToAngle(bmi.clamp(10.0, 40.0));
    final needleLength = radius - 10;

    final needlePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;

    // Needle path
    final needlePath = Path();
    needlePath.moveTo(
      center.dx + math.cos(needleAngle) * needleLength,
      center.dy + math.sin(needleAngle) * needleLength,
    );
    needlePath.lineTo(
      center.dx + math.cos(needleAngle + math.pi / 2) * 6,
      center.dy + math.sin(needleAngle + math.pi / 2) * 6,
    );
    needlePath.lineTo(
      center.dx + math.cos(needleAngle - math.pi / 2) * 6,
      center.dy + math.sin(needleAngle - math.pi / 2) * 6,
    );
    needlePath.close();

    canvas.drawPath(needlePath, needlePaint);

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 12, centerPaint);

    final centerBorderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, 12, centerBorderPaint);
  }

  double _bmiToAngle(double bmi) {
    // Map BMI (10-40) to angle (135° to 405° or 0.75π to 2.25π)
    final normalizedBMI = (bmi - 10).clamp(0.0, 30.0);
    return math.pi * 0.75 + (normalizedBMI / 30.0) * (math.pi * 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}