import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ManageIngredientsPage extends StatefulWidget {
  const ManageIngredientsPage({super.key});

  @override
  State<ManageIngredientsPage> createState() => _ManageIngredientsPageState();
}

class _ManageIngredientsPageState extends State<ManageIngredientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
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
                      hintText: 'Search ingredients by name...',
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
          
          const SizedBox(height: 24),
          
          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Ingredients', '234', Icons.eco, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Price Tracked', '189', Icons.trending_up, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Categories', '12', Icons.category, Colors.orange),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('Vegetables'),
                _buildCategoryChip('Meat'),
                _buildCategoryChip('Seafood'),
                _buildCategoryChip('Grains'),
                _buildCategoryChip('Spices'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Ingredient Database',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ingredient Cards
          ...List.generate(6, (index) => _buildIngredientCard(
            name: _getIngredientName(index),
            category: _getIngredientCategory(index),
            currentPrice: _getCurrentPrice(index),
            priceChange: _getPriceChange(index),
            lastUpdated: _getLastUpdated(index),
            nutritionHighlights: _getNutritionHighlights(index),
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
  
  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.successGreen : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.successGreen : AppColors.successGreen.withOpacity(0.3),
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.grayText,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildIngredientCard({
    required String name,
    required String category,
    required double currentPrice,
    required double priceChange,
    required String lastUpdated,
    required List<String> nutritionHighlights,
  }) {
    final bool isPriceUp = priceChange > 0;
    final Color priceColor = isPriceUp ? Colors.red : priceChange < 0 ? AppColors.successGreen : AppColors.grayText;
    
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
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(category),
                        ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isPriceUp ? Icons.trending_up : priceChange < 0 ? Icons.trending_down : Icons.trending_flat,
                        color: priceColor,
                        size: 16,
                      ),
                      Text(
                        '${priceChange > 0 ? '+' : ''}${priceChange.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: priceColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleIngredientAction(value, name);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('View Details')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit Ingredient')),
                  const PopupMenuItem(value: 'price', child: Text('Price History')),
                  const PopupMenuItem(value: 'usage', child: Text('Recipe Usage')),
                ],
              ),
            ],
          ),
          if (nutritionHighlights.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Nutrition Highlights:',
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.grayText,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: nutritionHighlights.map((highlight) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  highlight,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              )).toList(),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Last updated: $lastUpdated',
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 10,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables': return Colors.green;
      case 'meat': return Colors.red;
      case 'seafood': return Colors.blue;
      case 'grains': return Colors.orange;
      case 'spices': return Colors.purple;
      default: return AppColors.successGreen;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables': return Icons.eco;
      case 'meat': return Icons.local_dining;
      case 'seafood': return Icons.set_meal;
      case 'grains': return Icons.grain;
      case 'spices': return Icons.local_florist;
      default: return Icons.fastfood;
    }
  }
  
  void _handleIngredientAction(String action, String ingredientName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for $ingredientName')),
    );
  }
  
  String _getIngredientName(int index) {
    final names = ['Tomato', 'Chicken Breast', 'Bangus', 'Rice', 'Onion', 'Ginger'];
    return names[index];
  }
  
  String _getIngredientCategory(int index) {
    final categories = ['Vegetables', 'Meat', 'Seafood', 'Grains', 'Vegetables', 'Spices'];
    return categories[index];
  }
  
  double _getCurrentPrice(int index) {
    final prices = [45.0, 180.0, 150.0, 52.0, 35.0, 120.0];
    return prices[index];
  }
  
  double _getPriceChange(int index) {
    final changes = [5.2, -2.1, 8.5, 0.0, -1.5, 3.2];
    return changes[index];
  }
  
  String _getLastUpdated(int index) {
    final updates = ['2 hours ago', '1 day ago', '3 hours ago', '1 hour ago', '4 hours ago', '1 day ago'];
    return updates[index];
  }
  
  List<String> _getNutritionHighlights(int index) {
    final highlights = [
      ['Vitamin C', 'Lycopene'],
      ['High Protein', 'Low Fat'],
      ['Omega-3', 'High Protein'],
      ['Carbohydrates', 'B Vitamins'],
      ['Antioxidants', 'Vitamin C'],
      ['Anti-inflammatory']
    ];
    return highlights[index];
  }
}
