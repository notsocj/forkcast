import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ApprovePriceForecastsPage extends StatefulWidget {
  const ApprovePriceForecastsPage({super.key});

  @override
  State<ApprovePriceForecastsPage> createState() => _ApprovePriceForecastsPageState();
}

class _ApprovePriceForecastsPageState extends State<ApprovePriceForecastsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Price Forecast Approvals',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Pending Forecasts', '12', Icons.trending_up, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Approved Today', '8', Icons.check_circle, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Accuracy Rate', '94%', Icons.analytics, Colors.blue),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Forecast Cards
          ...List.generate(4, (index) => _buildForecastCard(
            ingredient: _getIngredientName(index),
            currentPrice: _getCurrentPrice(index),
            predictedPrice: _getPredictedPrice(index),
            confidence: _getConfidence(index),
            timeframe: _getTimeframe(index),
          )),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 11,
                color: AppColors.grayText,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildForecastCard({
    required String ingredient,
    required double currentPrice,
    required double predictedPrice,
    required double confidence,
    required String timeframe,
  }) {
    final double change = ((predictedPrice - currentPrice) / currentPrice) * 100;
    final bool isIncrease = change > 0;
    final Color changeColor = isIncrease ? Colors.red : AppColors.successGreen;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient,
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeframe,
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${predictedPrice.toStringAsFixed(2)}/kg',
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isIncrease ? Icons.trending_up : Icons.trending_down,
                        color: changeColor,
                        size: 16,
                      ),
                      Text(
                        '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Confidence: ${confidence.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  _approveForecast(ingredient);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Approve',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _rejectForecast(ingredient);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reject',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _approveForecast(String ingredient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved forecast for $ingredient')),
    );
  }
  
  void _rejectForecast(String ingredient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected forecast for $ingredient')),
    );
  }
  
  String _getIngredientName(int index) {
    final names = ['Tomato', 'Rice', 'Chicken', 'Onion'];
    return names[index];
  }
  
  double _getCurrentPrice(int index) {
    final prices = [45.0, 52.0, 180.0, 35.0];
    return prices[index];
  }
  
  double _getPredictedPrice(int index) {
    final prices = [48.5, 54.0, 175.0, 38.0];
    return prices[index];
  }
  
  double _getConfidence(int index) {
    final confidences = [87.0, 92.0, 78.0, 85.0];
    return confidences[index];
  }
  
  String _getTimeframe(int index) {
    final timeframes = ['7-day forecast', '7-day forecast', '14-day forecast', '7-day forecast'];
    return timeframes[index];
  }
}
