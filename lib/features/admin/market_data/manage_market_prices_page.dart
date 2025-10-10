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
    _initializeMarketPrices();
  }

  void _initializeMarketPrices() {
    // Initialize with the provided data
    _marketPrices = {
      "LocalCommercialRice": [
        {"product": "Premium", "unit": "Kilogram", "price": 39.33, "market": "Galas City-Owned Market"},
        {"product": "Regular Milled", "unit": "Kilogram", "price": 38.67, "market": "Roxas City-Owned Market"},
        {"product": "Special", "unit": "Kilogram", "price": 47.33, "market": "Galas City-Owned Market"},
        {"product": "Well-milled", "unit": "Kilogram", "price": 39.50, "market": "R.A Calalay City-Owned Market"}
      ],
      "LivestockAndPoultry": [
        {"product": "Beef Brisket", "unit": "Kilogram", "price": 42.00, "market": "Kamuning City-Owned Market"},
        {"product": "Beef Rump", "unit": "Kilogram", "price": 284.67, "market": "Galas City-Owned Market"},
        {"product": "Chicken Egg, Brown Extra Large", "unit": "PC", "price": 9.38, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Chicken Egg, Brown Large", "unit": "PC", "price": 10.00, "market": "R.A Calalay City-Owned Market / Project 4 City-Owned Market (New)"},
        {"product": "Chicken Egg, Brown Medium", "unit": "PC", "price": 10.67, "market": "R.A Calalay City-Owned Market"},
        {"product": "Chicken Egg, White Extra Large", "unit": "PC", "price": 9.50, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Chicken Egg, White Extra Small", "unit": "PC", "price": 6.75, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Chicken Egg, White Jumbo", "unit": "PC", "price": 10.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Chicken Egg, White Large", "unit": "PC", "price": 8.25, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Chicken Egg, White Medium", "unit": "PC", "price": 7.83, "market": "Kamuning City-Owned Market"},
        {"product": "Chicken Egg, White Pewee", "unit": "PC", "price": 8.00, "market": "Galas City-Owned Market"},
        {"product": "Chicken Egg, White Small", "unit": "PC", "price": 7.00, "market": "R.A Calalay City-Owned Market"},
        {"product": "Pork Belly, Liempo", "unit": "Kilogram", "price": 396.67, "market": "Murphy City-Owned Market"},
        {"product": "Pork Ham, Kasim", "unit": "Kilogram", "price": 356.67, "market": "Murphy City-Owned Market"},
        {"product": "Whole Chicken", "unit": "Kilogram", "price": 186.67, "market": "R.A Calalay City-Owned Market"}
      ],
      "HighlandVegetables": [
        {"product": "Bell Pepper, Green", "unit": "Kilogram", "price": 120.00, "market": "Project 2 City-Owned Market"},
        {"product": "Bell Pepper, Red", "unit": "Kilogram", "price": 120.00, "market": "Project 2 City-Owned Market"},
        {"product": "Broccoli", "unit": "Kilogram", "price": 175.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Cabbage, Rare Ball", "unit": "Kilogram", "price": 135.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Cabbage, Scorpio", "unit": "Kilogram", "price": 90.00, "market": "Murphy City-Owned Market"},
        {"product": "Cabbage, Wonder Ball", "unit": "Kilogram", "price": 90.00, "market": "Roxas City-Owned Market"},
        {"product": "Carrot", "unit": "Kilogram", "price": 90.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Chayote", "unit": "Kilogram", "price": 86.67, "market": "R.A Calalay City-Owned Market / Kamuning City-Owned Market"},
        {"product": "Habichuelas, Baguio Beans", "unit": "Kilogram", "price": 110.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Pechay, Baguio", "unit": "Kilogram", "price": 70.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "White, Potato", "unit": "Kilogram", "price": 96.67, "market": "R.A Calalay City-Owned Market"}
      ],
      "ImportedCommercialRice": [
        {"product": "Premium", "unit": "Kilogram", "price": 46.00, "market": "Murphy City-Owned Market"},
        {"product": "Regular Milled", "unit": "Kilogram", "price": 38.67, "market": "R.A Calalay City-Owned Market"},
        {"product": "Special", "unit": "Kilogram", "price": 49.67, "market": "Kamuning City-Owned Market"},
        {"product": "Well-Milled", "unit": "Kilogram", "price": 39.33, "market": "Kamuning City-Owned Market"}
      ],
      "Fish": [
        {"product": "Alumahan", "unit": "Kilogram", "price": 300.00, "market": "Roxas City-Owned Market / Project 4 City-Owned Market (New)"},
        {"product": "Bangus, Large", "unit": "Kilogram", "price": 210.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Bangus, Medium", "unit": "Kilogram", "price": 180.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Galunggong, Imported", "unit": "Kilogram", "price": 270.00, "market": "Galas City-Owned Market"},
        {"product": "Galunggong, Local", "unit": "Kilogram", "price": 250.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Salmon Head", "unit": "Kilogram", "price": 206.67, "market": "R.A Calalay City-Owned Market"},
        {"product": "Squid", "unit": "Kilogram", "price": 390.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Tamban", "unit": "Kilogram", "price": 145.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Tilapia", "unit": "Kilogram", "price": 140.00, "market": "R.A Calalay City-Owned Market"},
        {"product": "Yellow-Fin Tuna, Tambakol", "unit": "Kilogram", "price": 250.00, "market": "Project 2 City-Owned Market"}
      ],
      "Corn": [
        {"product": "Grits, Feed Grade", "unit": "Kilogram", "price": 47.00, "market": "Galas City-Owned Market"},
        {"product": "White Glutinous", "unit": "Kilogram", "price": 75.00, "market": "Galas City-Owned Market"},
        {"product": "White Grits, Food Grade", "unit": "Kilogram", "price": 52.00, "market": "Galas City-Owned Market"},
        {"product": "Yellow Cracked, Feed Grade", "unit": "Kilogram", "price": 45.00, "market": "Galas City-Owned Market"},
        {"product": "Yellow Grits, Food Grade", "unit": "Kilogram", "price": 50.00, "market": "Galas City-Owned Market"},
        {"product": "Yellow Sweet", "unit": "Kilogram", "price": 56.67, "market": "R.A Calalay City-Owned Market"}
      ],
      "LowlandVegetables": [
        {"product": "Ampalaya", "unit": "Kilogram", "price": 100.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Eggplant", "unit": "Kilogram", "price": 65.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Pechay Tagalog", "unit": "Kilogram", "price": 86.67, "market": "R.A Calalay City-Owned Market / Murphy City-Owned Market"},
        {"product": "Squash", "unit": "Kilogram", "price": 42.50, "market": "Project 4 City-Owned Market (New)"},
        {"product": "String Beans", "unit": "Kilogram", "price": 36.67, "market": "R.A Calalay City-Owned Market"},
        {"product": "Tomato", "unit": "Kilogram", "price": 45.00, "market": "Project 4 City-Owned Market (New)"}
      ],
      "Fruits": [
        {"product": "Banana, Lakatan", "unit": "Kilogram", "price": 90.00, "market": "Project 2 City-Owned Market"},
        {"product": "Banana, Latundan", "unit": "Kilogram", "price": 56.67, "market": "R.A Calalay City-Owned Market"},
        {"product": "Calamansi", "unit": "Kilogram", "price": 56.67, "market": "R.A Calalay City-Owned Market"},
        {"product": "Mango, Carabao", "unit": "Kilogram", "price": 190.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Papaya", "unit": "Kilogram", "price": 65.00, "market": "Project 2 City-Owned Market"}
      ],
      "OtherCommodities": [
        {"product": "Coconut Oil - 350mL", "unit": "ML", "price": 46.50, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Coconut Oil 1L", "unit": "L", "price": 115.00, "market": "Project 4 City-Owned Market (New)"},
        {"product": "Palm Oil - 1L", "unit": "L", "price": 72.00, "market": "Murphy City-Owned Market"},
        {"product": "Palm Oil - 350mL", "unit": "ML", "price": 30.00, "market": "Murphy City-Owned Market"},
        {"product": "Sugar Brown", "unit": "Kilogram", "price": 70.00, "market": "Kamuning City-Owned Market / Galas City-Owned Market"},
        {"product": "Sugar Refined", "unit": "Kilogram", "price": 79.33, "market": "R.A Calalay City-Owned Market"},
        {"product": "Sugar Washed", "unit": "Kilogram", "price": 73.33, "market": "Galas City-Owned Market"}
      ]
    };

    setState(() {
      _isLoading = false;
    });
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
        content: Column(
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
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'New Price (₱)',
                prefixText: '₱ ',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null && newPrice > 0) {
                // Update in local state
                setState(() {
                  _marketPrices[category]![index]['price'] = newPrice;
                });
                
                // Save to Firebase with today's date
                await _savePriceToFirebase(category, product, newPrice);
                
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
                    content: Text('Please enter a valid price'),
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

  Future<void> _savePriceToFirebase(String category, Map<String, dynamic> product, double newPrice) async {
    try {
      // Determine source type based on market name
      String sourceType = 'Public Market';
      if (product['market'].toString().contains('City-Owned')) {
        sourceType = 'City-Owned Market';
      } else if (product['market'].toString().contains('Private')) {
        sourceType = 'Private Market';
      }
      
      // Check if it's imported (for rice)
      bool isImported = category == 'ImportedCommercialRice';
      
      await _priceService.updateMarketPrice(
        category: _getCategoryDisplayName(category),
        productName: product['product'],
        marketName: product['market'],
        unit: product['unit'],
        priceMin: newPrice,
        sourceType: sourceType,
        isImported: isImported,
      );
      
      print('Price saved to Firebase for ${DateTime.now()}');
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
