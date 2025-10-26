import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/market_price_service.dart';

class ManageMarketPricesPage extends StatefulWidget {
  const ManageMarketPricesPage({super.key});

  @override
  State<ManageMarketPricesPage> createState() => _ManageMarketPricesPageState();
}

class _ManageMarketPricesPageState extends State<ManageMarketPricesPage> {
  final MarketPriceService _priceService = MarketPriceService();
  
  // Track which categories are expanded
  final Map<String, bool> _expandedCategories = {};
  
  // Market prices data structure
  Map<String, List<Map<String, dynamic>>> _marketPrices = {};
  
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMarketPricesFromFirebase();
  }

  Future<void> _loadMarketPricesFromFirebase() async {
    setState(() => _isLoading = true);
    
    try {
      // Get all categories from Firebase
      final categories = await _priceService.getAllCategories();
      
      // Load prices for each category
      Map<String, List<Map<String, dynamic>>> allPrices = {};
      
      for (String category in categories) {
        final pricesStream = _priceService.getPricesByCategory(category);
        final prices = await pricesStream.first;
        
        // Convert Firebase data to expected format
        final formattedPrices = prices.map((priceData) {
          return {
            'product': priceData['product_name'] ?? '',
            'unit': priceData['unit'] ?? '',
            'price': (priceData['price_min'] as num?)?.toDouble() ?? 0.0,
            'market': priceData['market_name'] ?? '',
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
    // Convert camelCase to Display Name
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Market Prices'),
          backgroundColor: AppColors.successGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.successGreen),
        ),
      );
    }

    final filteredCategories = _marketPrices.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      
      // Search in category name
      if (_getCategoryDisplayName(entry.key).toLowerCase().contains(_searchQuery.toLowerCase())) {
        return true;
      }
      
      // Search in products
      return entry.value.any((product) =>
        product['product'].toString().toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Manage Market Prices',
          style: TextStyle(
            fontFamily: AppConstants.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.successGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: 'Help & Info',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.successGreen,
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
                const Text(
                  'Quezon City Market Prices',
                  style: TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.category,
                      label: '${_marketPrices.length} Categories',
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.inventory_2,
                      label: '${_getTotalProducts()} Products',
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.store,
                      label: '8 Markets',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
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
                hintText: 'Search products or categories...',
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
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.successGreen.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.successGreen, width: 2),
                ),
              ),
            ),
          ),
          
          // Expandable categories list
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
      ),
    );
  }

  int _getTotalProducts() {
    return _marketPrices.values.fold(0, (sum, products) => sum + products.length);
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, List<Map<String, dynamic>> products, bool isExpanded) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
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
                          '${products.length} products',
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
          
          // Expandable content
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.05),
                      border: Border(
                        top: BorderSide(color: AppColors.successGreen.withOpacity(0.2)),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 3, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 1, child: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 2, child: Text('Price (₱)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 80, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  
                  // Product rows
                  ...products.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    return _buildProductRow(category, index, product);
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductRow(String category, int index, Map<String, dynamic> product) {
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
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product['market'],
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 11,
                    color: AppColors.grayText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              product['unit'],
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 12,
                color: AppColors.grayText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₱${product['price'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.successGreen,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showEditDialog(category, index, product),
                  color: AppColors.primaryAccent,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.history, size: 18),
                  onPressed: () => _showPriceHistory(product),
                  color: AppColors.successGreen,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'View History',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String category, int index, Map<String, dynamic> product) {
    final priceController = TextEditingController(text: product['price'].toString());
    final marketController = TextEditingController(text: product['market']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: AppColors.primaryAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Edit Price',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['product'],
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Current market: ${product['market']}',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 13,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: marketController,
                decoration: InputDecoration(
                  labelText: 'Market Name',
                  hintText: 'e.g., Galas City-Owned Market',
                  prefixIcon: const Icon(Icons.store, color: AppColors.successGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.successGreen, width: 2),
                  ),
                  helperText: 'Update the source market for this price',
                  helperStyle: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'New Price (₱)',
                  prefixText: '₱ ',
                  prefixIcon: const Icon(Icons.attach_money, color: AppColors.successGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.successGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.successGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price will be saved for today',
                            style: TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.successGreen,
                            ),
                          ),
                          Text(
                            DateFormat('MMMM d, yyyy').format(DateTime.now()),
                            style: const TextStyle(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text);
              final newMarket = marketController.text.trim();
              final oldMarket = product['market'] as String; // Store old market name
              
              if (newPrice != null && newPrice > 0 && newMarket.isNotEmpty) {
                // Save to Firebase with old and new market names
                await _savePriceToFirebase(category, product, newPrice, newMarket, oldMarket);
                
                // Reload data from Firebase to get latest prices
                await _loadMarketPricesFromFirebase();
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Price updated for ${DateFormat('MMM d').format(DateTime.now())}'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid price and market name'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePriceToFirebase(String category, Map<String, dynamic> product, double newPrice, String newMarket, String oldMarket) async {
    try {
      // Determine source type based on market name
      String sourceType = 'Public Market';
      if (newMarket.contains('City-Owned')) {
        sourceType = 'City-Owned Market';
      } else if (newMarket.contains('Private')) {
        sourceType = 'Private Market';
      }
      
      // Check if it's imported (for rice)
      bool isImported = category == 'ImportedCommercialRice';
      
      // If market name changed, we need to handle document migration
      if (oldMarket != newMarket) {
        print('🔄 Market name changed: $oldMarket → $newMarket');
        
        // Update with new market name (creates new document if needed)
        await _priceService.updateMarketPriceWithMarketChange(
          category: _getCategoryDisplayName(category),
          productName: product['product'],
          oldMarketName: oldMarket,
          newMarketName: newMarket,
          unit: product['unit'],
          priceMin: newPrice,
          sourceType: sourceType,
          isImported: isImported,
        );
      } else {
        // Market name unchanged, just update price
        await _priceService.updateMarketPrice(
          category: _getCategoryDisplayName(category),
          productName: product['product'],
          marketName: newMarket,
          unit: product['unit'],
          priceMin: newPrice,
          sourceType: sourceType,
          isImported: isImported,
        );
      }
      
      print('✅ Price saved to Firebase for ${DateTime.now()} at $newMarket');
    } catch (e) {
      print('Error saving price to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sync with database: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showPriceHistory(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history, color: AppColors.successGreen, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Price History',
                style: TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['product'],
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product['market'],
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 13,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildHistoryRow('Today', product['price'], isLatest: true),
                    const Divider(),
                    const Text(
                      'Historical data will be available after ML integration',
                      style: TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 12,
                        color: AppColors.grayText,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String date, dynamic price, {bool isLatest = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                date,
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 13,
                  color: isLatest ? AppColors.successGreen : AppColors.grayText,
                  fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isLatest) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            '₱${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 14,
              fontWeight: isLatest ? FontWeight.bold : FontWeight.w500,
              color: isLatest ? AppColors.successGreen : AppColors.blackText,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.successGreen),
            SizedBox(width: 12),
            Text('Market Prices Management'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                'How it works',
                'Market prices are organized by categories. Click on a category to expand and view all products with their current prices.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Editing Prices',
                'Click the edit icon (✏️) to update a product price. Each price update is saved with today\'s date for historical tracking.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Price History',
                'Click the history icon (🕐) to view past prices. This data is used for machine learning price forecasting.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Machine Learning',
                'Price updates are automatically stored in the database with timestamps. This data will be used to train ML models for price prediction.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppConstants.headingFont,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 13,
            color: AppColors.grayText,
          ),
        ),
      ],
    );
  }
}

