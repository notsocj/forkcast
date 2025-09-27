import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ManageMarketDataPage extends StatefulWidget {
  const ManageMarketDataPage({super.key});

  @override
  State<ManageMarketDataPage> createState() => _ManageMarketDataPageState();
}

class _ManageMarketDataPageState extends State<ManageMarketDataPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTimeframe = 'Today';
  String _selectedMarket = 'All Markets';
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filters
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.grayText.withOpacity(0.7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search price data...',
                            hintStyle: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              color: AppColors.grayText,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTimeframe,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Today', child: Text('Today')),
                        DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                        DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeframe = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMarket,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'All Markets', child: Text('All Markets')),
                        DropdownMenuItem(value: 'Quezon City', child: Text('Quezon City')),
                        DropdownMenuItem(value: 'Makati', child: Text('Makati')),
                        DropdownMenuItem(value: 'Mandaluyong', child: Text('Mandaluyong')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMarket = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Market Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Active Markets', '12', Icons.store, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Price Updates Today', '156', Icons.update, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Data Sources', '8', Icons.source, Colors.orange),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Market Price Data',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Price Data Cards
          ...List.generate(6, (index) => _buildPriceDataCard(
            ingredient: _getIngredient(index),
            market: _getMarket(index),
            currentPrice: _getCurrentPrice(index),
            previousPrice: _getPreviousPrice(index),
            trend: _getPriceTrend(index),
            lastUpdate: _getLastUpdate(index),
            reliability: _getReliability(index),
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
  
  Widget _buildPriceDataCard({
    required String ingredient,
    required String market,
    required double currentPrice,
    required double previousPrice,
    required String trend,
    required String lastUpdate,
    required double reliability,
  }) {
    final double priceChange = ((currentPrice - previousPrice) / previousPrice) * 100;
    final bool isPriceUp = priceChange > 0;
    final Color trendColor = isPriceUp ? Colors.red : priceChange < 0 ? AppColors.successGreen : AppColors.grayText;
    final Color reliabilityColor = reliability >= 90 ? AppColors.successGreen : reliability >= 70 ? Colors.orange : Colors.red;
    
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_grocery_store,
                  color: AppColors.successGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
                      market,
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
                    '₱${currentPrice.toStringAsFixed(2)}/kg',
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPriceUp ? Icons.trending_up : priceChange < 0 ? Icons.trending_down : Icons.trending_flat,
                        color: trendColor,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${priceChange > 0 ? '+' : ''}${priceChange.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handlePriceAction(value, ingredient);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'history', child: Text('Price History')),
                  const PopupMenuItem(value: 'alerts', child: Text('Set Alert')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit Price')),
                  const PopupMenuItem(value: 'verify', child: Text('Verify Data')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: reliabilityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reliability: ${reliability.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: reliabilityColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Updated: $lastUpdate',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 10,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _handlePriceAction(String action, String ingredient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for $ingredient')),
    );
  }
  
  String _getIngredient(int index) {
    final ingredients = ['Tomato', 'Chicken', 'Rice', 'Onion', 'Bangus', 'Pork'];
    return ingredients[index];
  }
  
  String _getMarket(int index) {
    final markets = ['Quezon City Public Market', 'Makati Palengke', 'Commonwealth Market', 'Balintawak Market', 'Marikina Public Market', 'Pasig Mega Market'];
    return markets[index];
  }
  
  double _getCurrentPrice(int index) {
    final prices = [45.0, 180.0, 52.0, 35.0, 150.0, 220.0];
    return prices[index];
  }
  
  double _getPreviousPrice(int index) {
    final prices = [42.0, 185.0, 52.0, 38.0, 140.0, 210.0];
    return prices[index];
  }
  
  String _getPriceTrend(int index) {
    final trends = ['Rising', 'Stable', 'Stable', 'Falling', 'Rising', 'Rising'];
    return trends[index];
  }
  
  String _getLastUpdate(int index) {
    final updates = ['2 hours ago', '1 hour ago', '3 hours ago', '1 day ago', '4 hours ago', '30 min ago'];
    return updates[index];
  }
  
  double _getReliability(int index) {
    final reliabilities = [95.0, 88.0, 92.0, 76.0, 90.0, 85.0];
    return reliabilities[index];
  }
}
