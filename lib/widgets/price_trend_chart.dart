import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants.dart';
import 'dart:math' as math;

/// Price Trend Chart Widget
/// Displays a line chart showing current price vs forecasted price trends
class PriceTrendChart extends StatelessWidget {
  final String productName;
  final double currentPrice;
  final double forecastedPrice;
  final String trend;
  final List<Map<String, dynamic>> historicalData;

  const PriceTrendChart({
    super.key,
    required this.productName,
    required this.currentPrice,
    required this.forecastedPrice,
    required this.trend,
    this.historicalData = const [],
  });

  @override
  Widget build(BuildContext context) {
    final bool isRising = trend == 'rising';
    final bool isFalling = trend == 'falling';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with product name and trend badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  productName,
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildTrendBadge(isRising, isFalling),
            ],
          ),
          const SizedBox(height: 24),
          
          // Chart
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size(double.infinity, 180),
              painter: _PriceTrendPainter(
                currentPrice: currentPrice,
                forecastedPrice: forecastedPrice,
                isRising: isRising,
                isFalling: isFalling,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Price summary
          Row(
            children: [
              Expanded(
                child: _buildPriceInfo(
                  'Current Price',
                  currentPrice,
                  AppColors.successGreen,
                  Icons.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceInfo(
                  'Forecasted Price',
                  forecastedPrice,
                  isRising ? Colors.red : (isFalling ? Colors.blue : AppColors.grayText),
                  Icons.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(bool isRising, bool isFalling) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;
    
    if (isRising) {
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red;
      icon = Icons.trending_up;
      label = 'Rising';
    } else if (isFalling) {
      bgColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue;
      icon = Icons.trending_down;
      label = 'Falling';
    } else {
      bgColor = AppColors.grayText.withOpacity(0.1);
      textColor = AppColors.grayText;
      icon = Icons.trending_flat;
      label = 'Stable';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, double price, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 11,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '₱${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: AppConstants.headingFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PriceTrendPainter extends CustomPainter {
  final double currentPrice;
  final double forecastedPrice;
  final bool isRising;
  final bool isFalling;

  _PriceTrendPainter({
    required this.currentPrice,
    required this.forecastedPrice,
    required this.isRising,
    required this.isFalling,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    
    // Calculate price range
    final minPrice = math.min(currentPrice, forecastedPrice) * 0.9;
    final maxPrice = math.max(currentPrice, forecastedPrice) * 1.1;
    final priceRange = maxPrice - minPrice;
    
    // Helper function to convert price to Y coordinate
    double priceToY(double price) {
      return height - ((price - minPrice) / priceRange) * height;
    }
    
    // Draw grid lines
    _drawGridLines(canvas, size);
    
    // Draw historical line (sample curve)
    _drawHistoricalLine(canvas, size, priceToY);
    
    // Draw forecast line
    _drawForecastLine(canvas, size, priceToY);
    
    // Draw data points
    _drawDataPoints(canvas, size, priceToY);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grayText.withOpacity(0.1)
      ..strokeWidth = 1;
    
    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawHistoricalLine(Canvas canvas, Size size, double Function(double) priceToY) {
    final paint = Paint()
      ..color = AppColors.successGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Generate sample historical curve (6 weeks of data leading to current price)
    final points = <Offset>[];
    for (int i = 0; i < 7; i++) {
      final x = size.width * (i / 8); // 7 historical points + 1 forecast point
      final progress = i / 6;
      
      // Create a smooth curve towards current price
      final basePrice = currentPrice * 0.92;
      final variation = math.sin(progress * math.pi * 2) * (currentPrice * 0.05);
      final price = basePrice + (currentPrice - basePrice) * progress + variation;
      
      final y = priceToY(price);
      points.add(Offset(x, y));
    }
    
    // Draw smooth curve through points
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prevPoint = points[i - 1];
      final point = points[i];
      final controlX = (prevPoint.dx + point.dx) / 2;
      path.quadraticBezierTo(
        controlX, prevPoint.dy,
        controlX, (prevPoint.dy + point.dy) / 2,
      );
      path.quadraticBezierTo(
        controlX, point.dy,
        point.dx, point.dy,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawForecastLine(Canvas canvas, Size size, double Function(double) priceToY) {
    final color = isRising ? Colors.red : (isFalling ? Colors.blue : AppColors.grayText);
    
    final dashedPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    
    // Draw dashed line from current to forecast
    final startX = size.width * (6 / 8);
    final endX = size.width;
    final startY = priceToY(currentPrice);
    final endY = priceToY(forecastedPrice);
    
    _drawDashedLine(canvas, Offset(startX, startY), Offset(endX, endY), dashedPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 8;
    const dashSpace = 4;
    
    final totalDistance = (end - start).distance;
    final numDashes = (totalDistance / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < numDashes; i++) {
      final progress1 = (i * (dashWidth + dashSpace)) / totalDistance;
      final progress2 = ((i * (dashWidth + dashSpace)) + dashWidth) / totalDistance;
      
      final point1 = Offset.lerp(start, end, progress1)!;
      final point2 = Offset.lerp(start, end, progress2)!;
      
      canvas.drawLine(point1, point2, paint);
    }
  }

  void _drawDataPoints(Canvas canvas, Size size, double Function(double) priceToY) {
    // Current price point
    final currentX = size.width * (6 / 8);
    final currentY = priceToY(currentPrice);
    
    final currentPaint = Paint()
      ..color = AppColors.successGreen
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(currentX, currentY), 5, currentPaint);
    canvas.drawCircle(
      Offset(currentX, currentY),
      7,
      Paint()
        ..color = AppColors.successGreen.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    
    // Forecast price point
    final forecastX = size.width;
    final forecastY = priceToY(forecastedPrice);
    
    final forecastColor = isRising ? Colors.red : (isFalling ? Colors.blue : AppColors.grayText);
    final forecastPaint = Paint()
      ..color = forecastColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(forecastX, forecastY), 5, forecastPaint);
    canvas.drawCircle(
      Offset(forecastX, forecastY),
      7,
      Paint()
        ..color = forecastColor.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
