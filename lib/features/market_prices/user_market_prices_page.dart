import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../services/market_price_service.dart';
import '../../widgets/price_trend_chart.dart';

class UserMarketPricesPage extends StatefulWidget {
  const UserMarketPricesPage({super.key});

  @override
  State<UserMarketPricesPage> createState() => _UserMarketPricesPageState();
}

class _UserMarketPricesPageState extends State<UserMarketPricesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MarketPriceService _marketPriceService = MarketPriceService();
  
  // Track which categories are expanded
  final Map<String, bool> _expandedCategories = {};
  
  // Market prices data structure
  Map<String, List<Map<String, dynamic>>> _marketPrices = {};
  
  bool _isLoading = true;
  String _searchQuery = '';
  
  // AI Forecasting data
  List<Map<String, dynamic>> _priceAlerts = [];
  Map<String, List<Map<String, dynamic>>> _forecastData = {};
  
  // Category filtering for Trends and Alerts tabs
  String _selectedCategory = 'All'; // 'All' or specific category
  final List<String> _availableCategories = [
    'All',
    'corn',
    'fish',
    'fruits',
    'livestock_and_poultry',
    'rice',
    'vegetables_highland',
    'vegetables_lowland',
  ];
  
  // Cache for loaded categories to minimize Firebase reads
  final Map<String, Map<String, List<Map<String, dynamic>>>> _categoryCache = {};
  bool _isForecastLoading = false;
  bool _isTopMoversLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketPricesFromFirebase();
    _loadForecastingData();
    _loadTopMovers(); // Load top movers independently
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadForecastingData() async {
    setState(() {
      _isForecastLoading = true;
    });
    
    try {
      // Check cache first to minimize Firebase reads
      if (_categoryCache.isEmpty) {
        // Initial load - load all categories at once
        final forecasts = await _marketPriceService.getForecastedPrices();
        _categoryCache['all'] = forecasts;
        
        setState(() {
          _forecastData = forecasts;
          _isForecastLoading = false;
        });
      } else if (_selectedCategory == 'All') {
        // Use cached data for 'All'
        setState(() {
          _forecastData = _categoryCache['all'] ?? {};
          _isForecastLoading = false;
        });
      } else {
        // Load specific category only if not cached
        if (!_categoryCache.containsKey(_selectedCategory)) {
          final categoryData = await _marketPriceService.getForecastsByCategory(_selectedCategory);
          _categoryCache[_selectedCategory] = {_selectedCategory: categoryData};
        }
        
        setState(() {
          _forecastData = _categoryCache[_selectedCategory] ?? {};
          _isForecastLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading forecasting data: $e');
      setState(() {
        _isForecastLoading = false;
      });
    }
  }
  
  Future<void> _loadTopMovers() async {
    setState(() {
      _isTopMoversLoading = true;
    });
    
    try {
      print('🔍 Loading top movers...');
      final topMovers = await _marketPriceService.getTopPriceMovers(limit: 15);
      print('✅ Top movers loaded: ${topMovers.length} items');
      setState(() {
        _priceAlerts = topMovers;
        _isTopMoversLoading = false;
      });
    } catch (e) {
      print('❌ Error loading top movers: $e');
      setState(() {
        _isTopMoversLoading = false;
      });
    }
  }
  
  // Called when category filter changes
  void _onCategoryChanged(String category) {
    if (_selectedCategory == category) return;
    
    setState(() {
      _selectedCategory = category;
    });
    
    // Reload data for selected category
    _loadForecastingData();
  }

  Future<void> _loadMarketPricesFromFirebase() async {
    setState(() => _isLoading = true);
    
    try {
      // Get all categories from Firebase
      final categories = await _marketPriceService.getAllCategories();
      
      // Load prices for each category
      Map<String, List<Map<String, dynamic>>> allPrices = {};
      
      for (String category in categories) {
        final pricesStream = _marketPriceService.getPricesByCategory(category);
        final prices = await pricesStream.first;
        
        // Convert Firebase data to expected format with trend calculation
        final formattedPrices = prices.map((priceData) {
          // Calculate trend based on price history if available
          String trend = 'stable'; // Default trend
          
          // TODO: Implement actual trend calculation from price_history
          // For now, use default 'stable' trend
          
          return {
            'product': priceData['product_name'] ?? '',
            'unit': priceData['unit'] ?? '',
            'price': (priceData['price_min'] as num?)?.toDouble() ?? 0.0,
            'market': priceData['market_name'] ?? '',
            'trend': trend,
            'id': priceData['id'] ?? '',
          };
        }).toList();
        
        allPrices[category] = formattedPrices;
      }
      
      setState(() {
        _marketPrices = allPrices;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading market prices: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load market prices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCategoryDisplayName(String key) {
    final Map<String, String> displayNames = {
      "All": "All Categories",
      "corn": "Corn",
      "fish": "Fish",
      "fruits": "Fruits",
      "livestock_and_poultry": "Livestock & Poultry",
      "rice": "Rice",
      "vegetables_highland": "Highland Vegetables",
      "vegetables_lowland": "Lowland Vegetables",
      // Legacy display names for Prices tab
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
    if (_isForecastLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.successGreen),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading price forecasts...',
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_forecastData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: AppColors.grayText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No forecast data available',
              style: TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.grayText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI forecasts will be generated weekly',
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 13,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
      );
    }

    // Flatten forecasts based on selected category
    final List<Map<String, dynamic>> displayForecasts = [];
    
    if (_selectedCategory == 'All') {
      _forecastData.forEach((category, products) {
        for (final product in products) {
          displayForecasts.add({
            ...product,
            'category': category,
          });
        }
      });
    } else {
      // Show only selected category
      final categoryProducts = _forecastData[_selectedCategory] ?? [];
      for (final product in categoryProducts) {
        displayForecasts.add({
          ...product,
          'category': _selectedCategory,
        });
      }
    }

    // Sort by absolute price change and take top 10
    displayForecasts.sort((a, b) {
      final aChange = ((a['forecasted_price'] ?? 0.0) - (a['current_price'] ?? 0.0)).abs();
      final bChange = ((b['forecasted_price'] ?? 0.0) - (b['current_price'] ?? 0.0)).abs();
      return bChange.compareTo(aChange);
    });

    final topForecasts = displayForecasts.take(10).toList();

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
            'AI-powered 7-day price forecasts',
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 16),
          
          // Category filter chips
          _buildCategoryFilterChips(),
          
          const SizedBox(height: 24),
          
          // Display forecast charts
          if (topForecasts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.filter_list_off,
                      size: 48,
                      color: AppColors.grayText.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No forecasts for ${_getCategoryDisplayName(_selectedCategory)}',
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...topForecasts.map((forecast) {
              final productName = forecast['product_name'] ?? 'Unknown Product';
              final currentPrice = (forecast['current_price'] ?? 0.0).toDouble();
              final forecastedPrice = (forecast['forecasted_price'] ?? 0.0).toDouble();
              final trend = forecast['trend'] ?? 'stable';
              
              return PriceTrendChart(
                productName: productName,
                currentPrice: currentPrice,
                forecastedPrice: forecastedPrice,
                trend: trend,
              );
            }).toList(),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.successGreen.withOpacity(0.1),
                  AppColors.primaryAccent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.successGreen,
                    size: 24,
                  ),
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
                          color: AppColors.blackText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Predictions based on 6 weeks of historical data and GPT-4 AI analysis',
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
  
  Widget _buildCategoryFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableCategories.length,
        itemBuilder: (context, index) {
          final category = _availableCategories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _getCategoryDisplayName(category),
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.blackText,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _onCategoryChanged(category);
                }
              },
              selectedColor: AppColors.successGreen,
              backgroundColor: AppColors.white,
              checkmarkColor: AppColors.white,
              side: BorderSide(
                color: isSelected 
                  ? AppColors.successGreen 
                  : AppColors.grayText.withOpacity(0.3),
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Top Price Movers',
                      style: TextStyle(
                        fontFamily: AppConstants.headingFont,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackText,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Products with biggest forecasted price changes',
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.primaryAccent,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Category filter chips
          _buildCategoryFilterChips(),
          
          const SizedBox(height: 24),
          
          // Loading state for top movers
          if (_isTopMoversLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.successGreen),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading price movers...',
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.grayText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_getFilteredAlerts().isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.filter_list_off,
                    size: 64,
                    color: AppColors.grayText.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _priceAlerts.isEmpty ? 'No price movers yet' : 'No price movers for ${_getCategoryDisplayName(_selectedCategory)}',
                    style: const TextStyle(
                      fontFamily: AppConstants.headingFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grayText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AI forecasts will be generated weekly',
                    style: TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 13,
                      color: AppColors.grayText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._getFilteredAlerts().map((alert) => _buildAlertCard(alert)).toList(),
        ],
      ),
    );
  }
  
  List<Map<String, dynamic>> _getFilteredAlerts() {
    if (_selectedCategory == 'All') {
      return _priceAlerts;
    }
    
    // Filter alerts by selected category
    return _priceAlerts.where((alert) {
      final category = alert['category'] as String? ?? '';
      return category == _selectedCategory;
    }).toList();
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final isIncrease = alert['isIncrease'] as bool? ?? false;
    final percentChange = (alert['percent_change'] as num?)?.toDouble() ?? 0.0;
    final currentPrice = (alert['current_price'] as num?)?.toDouble() ?? 0.0;
    final forecastedPrice = (alert['forecasted_price'] as num?)?.toDouble() ?? 0.0;
    final product = alert['product'] as String? ?? 'Unknown Product';
    final category = alert['category'] as String? ?? '';
    final confidence = alert['confidence'] as String? ?? 'medium';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isIncrease 
            ? Colors.red.withOpacity(0.3) 
            : Colors.blue.withOpacity(0.3),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isIncrease 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isIncrease ? Icons.trending_up : Icons.trending_down,
                  color: isIncrease ? Colors.red : Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 12,
                              color: AppColors.grayText,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(confidence).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            confidence.toUpperCase(),
                            style: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _getConfidenceColor(confidence),
                            ),
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
                    : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isIncrease ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isIncrease ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current',
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 10,
                          color: AppColors.grayText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₱${currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.grayText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Forecast',
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 10,
                          color: AppColors.grayText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₱${forecastedPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: AppConstants.headingFont,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isIncrease ? Colors.red : Colors.blue,
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

  Color _getConfidenceColor(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'high':
        return AppColors.successGreen;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return AppColors.grayText;
    }
  }
}
