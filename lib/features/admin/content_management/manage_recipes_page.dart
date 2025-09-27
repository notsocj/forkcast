import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';

class ManageRecipesPage extends StatefulWidget {
  const ManageRecipesPage({super.key});

  @override
  State<ManageRecipesPage> createState() => _ManageRecipesPageState();
}

class _ManageRecipesPageState extends State<ManageRecipesPage> {
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
                      hintText: 'Search recipes by name or ingredients...',
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
                child: _buildStatCard('Total Recipes', '456', Icons.restaurant_menu, AppColors.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Published', '398', Icons.check_circle, Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Pending Review', '58', Icons.pending, Colors.orange),
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
                _buildCategoryChip('Filipino'),
                _buildCategoryChip('Healthy'),
                _buildCategoryChip('Vegetarian'),
                _buildCategoryChip('Low Sodium'),
                _buildCategoryChip('Diabetes-Friendly'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Recipe Database',
            style: TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recipe Cards
          ...List.generate(5, (index) => _buildRecipeCard(
            name: _getRecipeName(index),
            description: _getRecipeDescription(index),
            kcal: _getRecipeKcal(index),
            servings: _getRecipeServings(index),
            tags: _getRecipeTags(index),
            rating: _getRecipeRating(index),
            status: _getRecipeStatus(index),
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
  
  Widget _buildRecipeCard({
    required String name,
    required String description,
    required int kcal,
    required int servings,
    required List<String> tags,
    required double rating,
    required String status,
  }) {
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppColors.successGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackText,
                            ),
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$kcal kcal',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.successGreen,
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
                            '$servings servings',
                            style: const TextStyle(
                              fontFamily: AppConstants.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: AppConstants.primaryFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grayText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleRecipeAction(value, name);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('View Recipe')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit Recipe')),
                  const PopupMenuItem(value: 'approve', child: Text('Approve')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
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
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color = status == 'Published' ? AppColors.successGreen : 
                 status == 'Pending' ? Colors.orange : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: AppConstants.primaryFont,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
  
  void _handleRecipeAction(String action, String recipeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for $recipeName')),
    );
  }
  
  String _getRecipeName(int index) {
    final names = ['Adobong Manok', 'Sinigang na Hipon', 'Grilled Bangus', 'Monggo Soup', 'Kare-Kareng Baka'];
    return names[index];
  }
  
  String _getRecipeDescription(int index) {
    final descriptions = [
      'Classic Filipino chicken adobo with soy sauce and vinegar',
      'Sour shrimp soup with vegetables and tamarind',
      'Healthy grilled milkfish with lemon and herbs',
      'Nutritious mung bean soup with vegetables',
      'Rich peanut stew with oxtail and vegetables'
    ];
    return descriptions[index];
  }
  
  int _getRecipeKcal(int index) {
    final kcals = [320, 180, 250, 160, 420];
    return kcals[index];
  }
  
  int _getRecipeServings(int index) {
    final servings = [4, 6, 2, 4, 6];
    return servings[index];
  }
  
  List<String> _getRecipeTags(int index) {
    final tags = [
      ['Filipino', 'Protein-Rich'],
      ['Low-Calorie', 'Healthy'],
      ['Heart-Healthy', 'Low-Sodium'],
      ['Vegetarian', 'High-Fiber'],
      ['Traditional', 'High-Protein']
    ];
    return tags[index];
  }
  
  double _getRecipeRating(int index) {
    final ratings = [4.8, 4.5, 4.7, 4.3, 4.6];
    return ratings[index];
  }
  
  String _getRecipeStatus(int index) {
    final statuses = ['Published', 'Published', 'Published', 'Pending', 'Published'];
    return statuses[index];
  }
}
