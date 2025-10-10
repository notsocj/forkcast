import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';

class UserMarketPricesPage extends StatefulWidget {
  const UserMarketPricesPage({super.key});

  @override
  State<UserMarketPricesPage> createState() => _UserMarketPricesPageState();
}

class _UserMarketPricesPageState extends State<UserMarketPricesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Track which categories are expanded
  final Map<String, bool> _expandedCategories = {};
  
  // Market prices data structure
  Map<String, List<Map<String, dynamic>>> _marketPrices = {};
  
  bool _isLoading = true;
  String _searchQuery = '';
  
  // Mock price alerts and trends data
  final List<Map<String, dynamic>> _priceAlerts = [
    {
      'product': 'Galunggong, Local',
      'change': '+8.3%',
      'isIncrease': true,
      'category': 'Fish',
      'newPrice': 250.00,
      'oldPrice': 230.00,
    },
    {
      'product': 'Tomato',
      'change': '-15.0%',
      'isIncrease': false,
      'category': 'Lowland Vegetables',
      'newPrice': 45.00,
      'oldPrice': 53.00,
    },
    {
      'product': 'Chicken Egg, White Medium',
      'change': '+5.2%',
      'isIncrease': true,
      'category': 'Livestock & Poultry',
      'newPrice': 7.83,
      'oldPrice': 7.44,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMarketPrices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeMarketPrices() {
    // Initialize with sample data (matching admin page structure)
    _marketPrices = {
      "LocalCommercialRice": [
        {"product": "Premium", "unit": "Kilogram", "price": 39.33, "market": "Galas City-Owned Market", "trend": "stable"},
        {"product": "Regular Milled", "unit": "Kilogram", "price": 38.67, "market": "Roxas City-Owned Market", "trend": "down"},
        {"product": "Special", "unit": "Kilogram", "price": 47.33, "market": "Galas City-Owned Market", "trend": "up"},
        {"product": "Well-milled", "unit": "Kilogram", "price": 39.50, "market": "R.A Calalay City-Owned Market", "trend": "stable"},
      ],
      "LivestockAndPoultry": [
        {"product": "Pork Belly, Liempo", "unit": "Kilogram", "price": 396.67, "market": "Murphy City-Owned Market", "trend": "up"},
        {"product": "Pork Ham, Kasim", "unit": "Kilogram", "price": 356.67, "market": "Murphy City-Owned Market", "trend": "stable"},
        {"product": "Whole Chicken", "unit": "Kilogram", "price": 186.67, "market": "R.A Calalay City-Owned Market", "trend": "down"},
        {"product": "Chicken Egg, White Medium", "unit": "PC", "price": 7.83, "market": "Kamuning City-Owned Market", "trend": "up"},
        {"product": "Beef Rump", "unit": "Kilogram", "price": 284.67, "market": "Galas City-Owned Market", "trend": "stable"},
      ],
      "Fish": [
        {"product": "Tilapia", "unit": "Kilogram", "price": 140.00, "market": "R.A Calalay City-Owned Market", "trend": "stable"},
        {"product": "Bangus, Large", "unit": "Kilogram", "price": 210.00, "market": "Project 4 City-Owned Market (New)", "trend": "up"},
        {"product": "Galunggong, Local", "unit": "Kilogram", "price": 250.00, "market": "Project 4 City-Owned Market (New)", "trend": "up"},
        {"product": "Alumahan", "unit": "Kilogram", "price": 300.00, "market": "Roxas City-Owned Market", "trend": "stable"},
      ],
      "Fruits": [
        {"product": "Banana, Lakatan", "unit": "Kilogram", "price": 90.00, "market": "Project 2 City-Owned Market", "trend": "stable"},
        {"product": "Banana, Latundan", "unit": "Kilogram", "price": 56.67, "market": "R.A Calalay City-Owned Market", "trend": "down"},
        {"product": "Mango, Carabao", "unit": "Kilogram", "price": 190.00, "market": "Project 4 City-Owned Market (New)", "trend": "up"},
        {"product": "Papaya", "unit": "Kilogram", "price": 65.00, "market": "Project 2 City-Owned Market", "trend": "stable"},
      ],
      "LowlandVegetables": [
        {"product": "Ampalaya", "unit": "Kilogram", "price": 100.00, "market": "Project 4 City-Owned Market (New)", "trend": "stable"},
        {"product": "Eggplant", "unit": "Kilogram", "price": 65.00, "market": "Project 4 City-Owned Market (New)", "trend": "down"},
        {"product": "Tomato", "unit": "Kilogram", "price": 45.00, "market": "Project 4 City-Owned Market (New)", "trend": "down"},
        {"product": "Squash", "unit": "Kilogram", "price": 42.50, "market": "Project 4 City-Owned Market (New)", "trend": "stable"},
      ],
      "OtherCommodities": [
        {"product": "Coconut Oil 1L", "unit": "L", "price": 115.00, "market": "Project 4 City-Owned Market (New)", "trend": "up"},
        {"product": "Palm Oil - 1L", "unit": "L", "price": 72.00, "market": "Murphy City-Owned Market", "trend": "stable"},
        {"product": "Sugar Refined", "unit": "Kilogram", "price": 79.33, "market": "R.A Calalay City-Owned Market", "trend": "up"},
      ],
    };

    setState(() {
      _isLoading = false;
    });
  }

  String _getCategoryDisplayName(String key) {
    final Map<String, String> displayNames = {
      "LocalCommercialRice": "Local Commercial Rice",
      "LivestockAndPoultry": "Livestock & Poultry",
      "HighlandVegetables": "Highland Vegetables",
      "ImportedCommercialRice": "Imported Commercial Rice",
      "Fish": "Fish",
      "Corn": "Corn",
      "LowlandVegetables": "Lowland Vegetables",
      "Fruits": "Fruits",
      "OtherCommodities": "Other Commodities"
    };
    return displayNames[key] ?? key;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "LocalCommercialRice":
      case "ImportedCommercialRice":
        return Icons.rice_bowl;
      case "LivestockAndPoultry":
        return Icons.pets;
      case "HighlandVegetables":
      case "LowlandVegetables":
        return Icons.grass;
      case "Fish":
        return Icons.set_meal;
      case "Corn":
        return Icons.agriculture;
      case "Fruits":
        return Icons.apple;
      case "OtherCommodities":
        return Icons.shopping_basket;
      default:
        return Icons.shopping_cart;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'up':
        return Colors.red;
      case 'down':
        return AppColors.successGreen;
      case 'stable':
        return Colors.orange;
      default:
        return AppColors.grayText;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      case 'stable':
        return Icons.trending_flat;
      default:
        return Icons.remove;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.successGreen,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Green Header
            _buildHeader(),
            
            // Tab Bar
            Container(
              color: AppColors.successGreen,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.white,
                indicatorWeight: 3,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.white.withOpacity(0.6),
                labelStyle: const TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Prices'),
                  Tab(text: 'Trends'),
                  Tab(text: 'Alerts'),
                ],
              ),
            ),
            
            // White Content Container
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPricesTab(),
                    _buildTrendsTab(),
                    _buildAlertsTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successGreen,
            AppColors.successGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Market Prices',
                      style: TextStyle(
                        fontFamily: AppConstants.headingFont,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quezon City Markets',
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Updated: ${DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now())}',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 12,
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricesTab() {
    final filteredCategories = _marketPrices.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      
      if (_getCategoryDisplayName(entry.key).toLowerCase().contains(_searchQuery.toLowerCase())) {
        return true;
      }
      
      return entry.value.any((product) =>
        product['product'].toString().toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                color: AppColors.grayText,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.successGreen),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.primaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        
        // Categories list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              final entry = filteredCategories[index];
              final category = entry.key;
              final products = entry.value;
              final isExpanded = _expandedCategories[category] ?? false;
              
              return _buildCategoryCard(category, products, isExpanded);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category, List<Map<String, dynamic>> products, bool isExpanded) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
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
                          _getCategoryDisplayName(category),
                          style: const TextStyle(
                            fontFamily: AppConstants.headingFont,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${products.length} products available',
                          style: const TextStyle(
                            fontFamily: AppConstants.primaryFont,
                            fontSize: 13,
                            color: AppColors.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.successGreen,
                  ),
                ],
              ),
            ),
          ),
          
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: products.map((product) => _buildProductItem(product)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['product'],
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.grayText,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product['market'],
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 11,
                          color: AppColors.grayText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${product['price'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    _getTrendIcon(product['trend']),
                    size: 14,
                    color: _getTrendColor(product['trend']),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product['unit'],
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 11,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Trends & Forecasts',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'View historical price changes and 7-day forecasts',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildTrendCard(
            'Galunggong, Local',
            'Fish',
            250.00,
            268.00,
            '+7.2%',
            true,
          ),
          _buildTrendCard(
            'Tomato',
            'Lowland Vegetables',
            45.00,
            40.50,
            '-10.0%',
            false,
          ),
          _buildTrendCard(
            'Pork Belly, Liempo',
            'Livestock & Poultry',
            396.67,
            415.00,
            '+4.6%',
            true,
          ),
          _buildTrendCard(
            'Mango, Carabao',
            'Fruits',
            190.00,
            175.00,
            '-7.9%',
            false,
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryAccent.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AI-Powered Forecasts',
                        style: TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Predictions are based on historical data and market trends',
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 11,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    String product,
    String category,
    double currentPrice,
    double forecastPrice,
    String changePercent,
    bool isIncrease,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isIncrease 
            ? Colors.red.withOpacity(0.3) 
            : AppColors.successGreen.withOpacity(0.3),
          width: 1.5,
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product,
                      style: const TextStyle(
                        fontFamily: AppConstants.headingFont,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isIncrease 
                    ? Colors.red.withOpacity(0.1) 
                    : AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isIncrease ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isIncrease ? Colors.red : AppColors.successGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      changePercent,
                      style: TextStyle(
                        fontFamily: AppConstants.headingFont,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isIncrease ? Colors.red : AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceBox(
                  'Current',
                  currentPrice,
                  AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                color: AppColors.grayText,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceBox(
                  '7-Day Forecast',
                  forecastPrice,
                  isIncrease ? Colors.red : AppColors.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(String label, double price, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 11,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₱${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Alerts',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Significant price changes in the last 7 days',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 24),
          
          ..._priceAlerts.map((alert) => _buildAlertCard(alert)).toList(),
          
          if (_priceAlerts.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppColors.grayText.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No price alerts',
                    style: TextStyle(
                      fontFamily: AppConstants.headingFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grayText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'ll notify you of significant price changes',
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 13,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final isIncrease = alert['isIncrease'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isIncrease 
            ? Colors.red.withOpacity(0.3) 
            : AppColors.successGreen.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncrease 
                ? Colors.red.withOpacity(0.1) 
                : AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
              color: isIncrease ? Colors.red : AppColors.successGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['product'],
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert['category'],
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₱${alert['oldPrice'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 13,
                        color: AppColors.grayText,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: AppColors.grayText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₱${alert['newPrice'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: AppConstants.headingFont,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isIncrease ? Colors.red : AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isIncrease 
                ? Colors.red.withOpacity(0.1) 
                : AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              alert['change'],
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isIncrease ? Colors.red : AppColors.successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
