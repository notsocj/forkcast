import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/progress_pill.dart';
import '../../providers/profile_setup_provider.dart';
import 'weekly_budget_page.dart';

class WeightInputPage extends StatefulWidget {
  const WeightInputPage({super.key});

  @override
  State<WeightInputPage> createState() => _WeightInputPageState();
}

class _WeightInputPageState extends State<WeightInputPage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  
  // Weight state
  double _weightKg = 85.0; // Default weight in kg
  bool _isMetric = true; // true for kg, false for lb
  bool _canContinue = true; // Default to true since we have default values

  // Ruler configuration
  static const double _minWeightKg = 30.0;
  static const double _maxWeightKg = 200.0;
  static const double _pixelsPerKg = 8.0; // How many pixels per kg on the ruler

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeight(_weightKg);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToWeight(double weightKg) {
    final double targetOffset = (weightKg - _minWeightKg) * _pixelsPerKg;
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onRulerScroll() {
    final double scrollOffset = _scrollController.offset;
    final double newWeightKg = _minWeightKg + (scrollOffset / _pixelsPerKg);
    setState(() {
      _weightKg = newWeightKg.clamp(_minWeightKg, _maxWeightKg);
    });
  }

  String get _displayWeight {
    if (_isMetric) {
      return _weightKg.toStringAsFixed(1);
    } else {
      // Convert kg to pounds
      double weightLb = _weightKg * 2.20462;
      return weightLb.toStringAsFixed(1);
    }
  }

  String get _displayUnit {
    return _isMetric ? 'kg' : 'lb';
  }

  void _toggleUnit(bool isMetric) {
    setState(() {
      _isMetric = isMetric;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.blackText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ProgressPill(current: 5, total: 8, width: 200),
            const SizedBox(width: 12),
            const Text(
              '5/8',
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 14,
                color: AppColors.blackText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Top spacing and title
                const SizedBox(height: 40),
                Text(
                  "What's your current\nweight?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Unit toggle buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUnitButton('kg', _isMetric, () => _toggleUnit(true)),
                    const SizedBox(width: 20),
                    _buildUnitButton('lb', !_isMetric, () => _toggleUnit(false)),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Weight display
                Text(
                  '$_displayWeight $_displayUnit',
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Ruler section
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ruler with center indicator
                        SizedBox(
                          height: 120,
                          child: Stack(
                            children: [
                              // Scrollable ruler
                              NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification is ScrollUpdateNotification) {
                                    _onRulerScroll();
                                  }
                                  return false;
                                },
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2 - 20),
                                  child: Container(
                                    height: 80,
                                    width: (_maxWeightKg - _minWeightKg) * _pixelsPerKg,
                                    child: CustomPaint(
                                      painter: WeightRulerPainter(),
                                      size: Size((_maxWeightKg - _minWeightKg) * _pixelsPerKg, 80),
                                    ),
                                  ),
                                ),
                              ),
                              // Center indicator (green line)
                              Positioned(
                                left: MediaQuery.of(context).size.width / 2 - 24 - 1,
                                top: 0,
                                child: Container(
                                  width: 2,
                                  height: 80,
                                  color: AppColors.successGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Weight range labels
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '80',
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 14,
                                  color: AppColors.grayText,
                                ),
                              ),
                              Text(
                                '90',
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 14,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Input field display (matches reference)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.successGreen, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _displayWeight,
                                style: const TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.successGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _displayUnit,
                                  style: const TextStyle(
                                    fontFamily: AppConstants.primaryFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Continue Button pinned to bottom
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _handleContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canContinue
                          ? AppColors.successGreen
                          : AppColors.grayText.withOpacity(0.3),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitButton(String unit, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.successGreen.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.successGreen : AppColors.grayText.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.successGreen : AppColors.blackText,
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    // Save weight to profile setup provider
    final profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);
    profileProvider.setWeight(_weightKg);

    // Navigate to weekly budget page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeeklyBudgetPage()),
    );
  }
}

class WeightRulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint tickPaint = Paint()
      ..color = AppColors.grayText.withOpacity(0.6)
      ..strokeWidth = 1;

    final Paint majorTickPaint = Paint()
      ..color = AppColors.grayText
      ..strokeWidth = 2;

    // Draw ruler ticks for weight (30kg to 200kg)
    for (int kg = 30; kg <= 200; kg++) {
      final double x = (kg - 30) * _WeightInputPageState._pixelsPerKg;
      final bool isMajorTick = kg % 10 == 0;
      final double tickHeight = isMajorTick ? 30 : 15;
      
      canvas.drawLine(
        Offset(x, size.height - tickHeight),
        Offset(x, size.height),
        isMajorTick ? majorTickPaint : tickPaint,
      );
      
      // Draw labels for major ticks
      if (isMajorTick && kg % 20 == 0) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: kg.toString(),
            style: TextStyle(
              color: AppColors.grayText,
              fontSize: 12,
              fontFamily: AppConstants.primaryFont,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - tickHeight - 20),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}