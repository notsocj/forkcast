import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/progress_pill.dart';
import 'weight_input_page.dart';

class HeightInputPage extends StatefulWidget {
  const HeightInputPage({super.key});

  @override
  State<HeightInputPage> createState() => _HeightInputPageState();
}

class _HeightInputPageState extends State<HeightInputPage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  
  // Height state
  double _heightCm = 175.0; // Default height in cm
  bool _isMetric = true; // true for cm, false for ft
  bool _canContinue = true; // Default to true since we have default values

  // Ruler configuration
  static const double _minHeightCm = 100.0;
  static const double _maxHeightCm = 250.0;
  static const double _pixelsPerCm = 4.0; // How many pixels per cm on the ruler

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToHeight(_heightCm);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToHeight(double heightCm) {
    final double targetOffset = (heightCm - _minHeightCm) * _pixelsPerCm;
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onRulerScroll() {
    final double scrollOffset = _scrollController.offset;
    final double newHeightCm = _minHeightCm + (scrollOffset / _pixelsPerCm);
    setState(() {
      _heightCm = newHeightCm.clamp(_minHeightCm, _maxHeightCm);
    });
  }

  String get _displayHeight {
    if (_isMetric) {
      return _heightCm.toStringAsFixed(1);
    } else {
      // Convert cm to feet and inches
      double totalInches = _heightCm / 2.54;
      int feet = (totalInches / 12).floor();
      int inches = (totalInches % 12).round();
      return '$feet\'$inches"';
    }
  }

  String get _displayUnit {
    return _isMetric ? 'cm' : 'ft';
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
            const ProgressPill(current: 4, total: 8, width: 200),
            const SizedBox(width: 12),
            const Text(
              '4/8',
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
                  "How tall are you?",
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
                    _buildUnitButton('cm', _isMetric, () => _toggleUnit(true)),
                    const SizedBox(width: 20),
                    _buildUnitButton('ft', !_isMetric, () => _toggleUnit(false)),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Height display
                Text(
                  '$_displayHeight $_displayUnit',
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
                                    width: (_maxHeightCm - _minHeightCm) * _pixelsPerCm,
                                    child: CustomPaint(
                                      painter: RulerPainter(),
                                      size: Size((_maxHeightCm - _minHeightCm) * _pixelsPerCm, 80),
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
                        
                        // Height range labels
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '170',
                                style: TextStyle(
                                  fontFamily: AppConstants.primaryFont,
                                  fontSize: 14,
                                  color: AppColors.grayText,
                                ),
                              ),
                              Text(
                                '180',
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
                                _displayHeight,
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
    // TODO: Save height to user profile and navigate to next setup page
    // Navigate to weight input page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeightInputPage()),
    );
  }
}

class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint tickPaint = Paint()
      ..color = AppColors.grayText.withOpacity(0.6)
      ..strokeWidth = 1;

    final Paint majorTickPaint = Paint()
      ..color = AppColors.grayText
      ..strokeWidth = 2;

    // Draw ruler ticks
    for (int cm = 100; cm <= 250; cm++) {
      final double x = (cm - 100) * _HeightInputPageState._pixelsPerCm;
      final bool isMajorTick = cm % 10 == 0;
      final double tickHeight = isMajorTick ? 30 : 15;
      
      canvas.drawLine(
        Offset(x, size.height - tickHeight),
        Offset(x, size.height),
        isMajorTick ? majorTickPaint : tickPaint,
      );
      
      // Draw labels for major ticks
      if (isMajorTick && cm % 20 == 0) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: cm.toString(),
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