import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';

class MarketPriceDashboardPage extends StatefulWidget {
  const MarketPriceDashboardPage({super.key});

  @override
  State<MarketPriceDashboardPage> createState() => _MarketPriceDashboardPageState();
}

class _MarketPriceDashboardPageState extends State<MarketPriceDashboardPage> {
  String _selectedTrendItem = 'Rice';

  // Sample data for recent prices
  final List<Map<String, dynamic>> _recentPrices = [
    {
      'name': 'Spinach',
      'subtitle': 'Kangkong • 1 kg',
  'price': 'PHP 65.00',
      'icon': Icons.eco,
      'color': AppColors.successGreen,
    },
    {
      'name': 'Chicken',
      'subtitle': 'Meat • 1 kg',
  'price': 'PHP 185.00',
      'icon': Icons.egg,
      'color': AppColors.primaryAccent,
    },
    {
      'name': 'Rice',
      'subtitle': 'Grains • 1 kg',
  'price': 'PHP 45.00',
      'icon': Icons.rice_bowl,
      'color': Colors.amber,
    },
    {
      'name': 'Tilapia',
      'subtitle': 'Fish • 1 kg',
  'price': 'PHP 120.00',
      'icon': Icons.set_meal,
      'color': Colors.blue,
    },
  ];

  // Sample data for price alerts
  final List<Map<String, dynamic>> _priceAlerts = [
    {
      'title': 'Pork prices increased by 12%',
      'subtitle': 'Pork prices are expected to rise further due to African swine flu impact.',
      'change': '+12%',
      'isIncrease': true,
    },
    {
      'title': 'Tomato prices dropped by 15%',
      'subtitle': 'Great time to buy tomatoes as local harvest increases supply.',
      'change': '-15%',
      'isIncrease': false,
    },
    {
      'title': 'Onion prices stable after weeks of fluctuation',
      'subtitle': 'Prices expected to remain stable for the next few weeks.',
      'change': 'Stable',
      'isIncrease': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh market price data - would call actual API in real app
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.successGreen,
          child: SingleChildScrollView(
            child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main content with rounded container
              Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Prices Section
                      _buildRecentPricesSection(),
                      
                      const SizedBox(height: 30),
                      
                      // Price Alerts Section
                      _buildPriceAlertsSection(),
                      
                      const SizedBox(height: 30),
                      
                      // Price Trends Section
                      _buildPriceTrendsSection(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Market Prices',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time prices from local markets',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 16,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPricesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Prices',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.3),
                ),
              ),
              child: Text(
                'All',
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Recent prices list
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _recentPrices.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == _recentPrices.length - 1;
              
              return Column(
                children: [
                  _buildPriceItem(
                    icon: item['icon'],
                    iconColor: item['color'],
                    name: item['name'],
                    subtitle: item['subtitle'],
                    price: item['price'],
                  ),
                  if (!isLast) const SizedBox(height: 12),
                  if (!isLast) Divider(
                    color: AppColors.lightGray.withOpacity(0.5),
                    thickness: 1,
                  ),
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem({
    required IconData icon,
    required Color iconColor,
    required String name,
    required String subtitle,
    required String price,
  }) {
    final displayPrice = price.trim().toUpperCase().startsWith('PHP') ? price : 'PHP $price';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackText,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ),
        Text(
          displayPrice,
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Alerts',
          style: TextStyle(
            fontFamily: AppConstants.headingFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Price alerts list
        Column(
          children: _priceAlerts.map((alert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert['title'],
                          style: TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackText,
                          ),
                        ),
                      ),
                      if (alert['isIncrease'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: alert['isIncrease'] == true 
                                ? Colors.red.withOpacity(0.1)
                                : AppColors.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            alert['change'],
                            style: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: alert['isIncrease'] == true 
                                  ? Colors.red
                                  : AppColors.successGreen,
                            ),
                          ),
                        ),
                      if (alert['isIncrease'] == null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            alert['change'],
                            style: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert['subtitle'],
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 13,
                      color: AppColors.grayText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price Trends',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blackText,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.3),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTrendItem,
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.successGreen,
                    size: 16,
                  ),
                  items: ['Rice', 'Chicken', 'Pork', 'Fish', 'Vegetables'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTrendItem = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Price trend chart placeholder
        Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chart area placeholder with trend lines
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Grid lines
                      CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: _GridPainter(),
                      ),
                      // Trend lines
                      CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: _TrendLinePainter(),
                      ),
                      // Price points
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: _buildPricePoint('PHP 42.00', Colors.orange),
                      ),
                      Positioned(
                        bottom: 35,
                        left: 80,
                        child: _buildPricePoint('PHP 45.00', Colors.blue),
                      ),
                      Positioned(
                        bottom: 45,
                        right: 80,
                        child: _buildPricePoint('PHP 48.00', Colors.orange),
                      ),
                      Positioned(
                        bottom: 40,
                        right: 20,
                        child: _buildPricePoint('PHP 47.00', Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Time labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jan 15', style: _timeAxisStyle()),
                  Text('Feb 15', style: _timeAxisStyle()),
                  Text('Mar 15', style: _timeAxisStyle()),
                  Text('Apr 15', style: _timeAxisStyle()),
                  Text('May 15', style: _timeAxisStyle()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricePoint(String price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        price,
        style: TextStyle(
          fontFamily: AppConstants.primaryFont,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  TextStyle _timeAxisStyle() {
    return TextStyle(
      fontFamily: AppConstants.primaryFont,
      fontSize: 11,
      color: AppColors.grayText,
    );
  }
}

// Custom painter for grid lines
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lightGray.withOpacity(0.3)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 1; i <= 4; i++) {
      final y = size.height / 5 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical grid lines
    for (int i = 1; i <= 4; i++) {
      final x = size.width / 5 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for trend lines
class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Orange trend line
    final path1 = Path();
    path1.moveTo(20, size.height - 20);
    path1.lineTo(size.width * 0.3, size.height - 50);
    path1.lineTo(size.width * 0.7, size.height - 30);
    path1.lineTo(size.width - 20, size.height - 40);
    
    canvas.drawPath(path1, paint1);

    // Blue trend line
    final path2 = Path();
    path2.moveTo(20, size.height - 40);
    path2.lineTo(size.width * 0.3, size.height - 35);
    path2.lineTo(size.width * 0.7, size.height - 60);
    path2.lineTo(size.width - 20, size.height - 45);
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}