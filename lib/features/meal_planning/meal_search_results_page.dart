import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'recipe_detail_page.dart';

class MealSearchResultsPage extends StatefulWidget {
  final String searchQuery;
  
  const MealSearchResultsPage({
    super.key,
    required this.searchQuery,
  });

  @override
  State<MealSearchResultsPage> createState() => _MealSearchResultsPageState();
}

class _MealSearchResultsPageState extends State<MealSearchResultsPage> {
  late TextEditingController _searchController;
  
  // Sample data for search results - in a real app, this would come from a database
  final Map<String, List<Map<String, dynamic>>> _searchResults = {
    'chicken': [
      {
        'name': 'Chicken Adobo',
        'description': 'Classic Filipino dish with chicken, soy sauce, and vinegar',
        'image': 'assets/images/chicken_adobo.jpg',
        'calories': '140-160 kcal',
        'prepTime': '30 min',
        'difficulty': 'Easy',
        'ingredients': ['Chicken', 'Soy sauce', 'Vinegar', 'Garlic', 'Bay leaves'],
        'tags': ['Filipino', 'Main dish', 'Low sodium'],
        'instructions': [
          'Clean and cut the chicken into serving pieces.',
          'In a pot, combine chicken, soy sauce, vinegar, garlic, and bay leaves.',
          'Marinate for at least 30 minutes.',
          'Bring to a boil without stirring, then simmer for 20-30 minutes.',
          'Season with salt and pepper to taste.',
          'Serve hot with steamed rice.'
        ],
      },
      {
        'name': 'Chicken Afritada',
        'description': 'Filipino-style stew with tender chicken, potatoes, carrots, and bell peppers simmered in rich tomato sauce',
        'image': 'assets/images/chicken_afritada.jpg',
        'calories': '220-280 kcal',
        'prepTime': '45 min',
        'difficulty': 'Medium',
        'ingredients': ['Chicken', 'Tomato sauce', 'Potatoes', 'Carrots', 'Bell peppers'],
        'tags': ['Filipino', 'Stew', 'Comfort food'],
        'instructions': [
          'Cut chicken into serving pieces and season with salt and pepper.',
          'Heat oil in a large pot and brown the chicken pieces.',
          'Add onions and garlic, sauté until fragrant.',
          'Pour in tomato sauce and water, bring to a boil.',
          'Add potatoes and carrots, simmer for 15 minutes.',
          'Add bell peppers and cook for another 5 minutes.',
          'Season with salt and pepper, serve hot.'
        ],
      },
    ],
    'adobo': [
      {
        'name': 'Chicken Adobo',
        'description': 'Classic Filipino dish with chicken, soy sauce, and vinegar',
        'image': 'assets/images/chicken_adobo.jpg',
        'calories': '140-160 kcal',
        'prepTime': '30 min',
        'difficulty': 'Easy',
        'ingredients': ['Chicken', 'Soy sauce', 'Vinegar', 'Garlic', 'Bay leaves'],
        'tags': ['Filipino', 'Main dish', 'Low sodium'],
        'instructions': [
          'Clean and cut the chicken into serving pieces.',
          'In a pot, combine chicken, soy sauce, vinegar, garlic, and bay leaves.',
          'Marinate for at least 30 minutes.',
          'Bring to a boil without stirring, then simmer for 20-30 minutes.',
          'Season with salt and pepper to taste.',
          'Serve hot with steamed rice.'
        ],
      },
      {
        'name': 'Pork Adobo',
        'description': 'Traditional pork adobo with soy sauce and vinegar',
        'image': 'assets/images/pork_adobo.jpg',
        'calories': '280-320 kcal',
        'prepTime': '35 min',
        'difficulty': 'Easy',
        'ingredients': ['Pork', 'Soy sauce', 'Vinegar', 'Garlic', 'Bay leaves'],
        'tags': ['Filipino', 'Main dish', 'Traditional'],
        'instructions': [
          'Cut pork into cubes and season with salt and pepper.',
          'In a pot, combine pork, soy sauce, vinegar, garlic, and bay leaves.',
          'Marinate for at least 30 minutes.',
          'Bring to a boil without stirring, then simmer for 30-40 minutes.',
          'Cook until pork is tender and sauce is reduced.',
          'Serve hot with steamed rice.'
        ],
      },
    ],
  };

  List<Map<String, dynamic>> get _currentResults {
    final query = widget.searchQuery.toLowerCase();
    return _searchResults[query] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            _buildHeader(),
            // Main content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: _currentResults.isEmpty
                    ? _buildNoResultsView()
                    : _buildResultsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealSearchResultsPage(searchQuery: value),
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search recipes...',
                  hintStyle: TextStyle(
                    color: AppColors.grayText,
                    fontFamily: 'OpenSans',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.grayText,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.grayText.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No recipes found',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.blackText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for "${widget.searchQuery}" with different keywords or browse our categories.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'Results for "${widget.searchQuery}" (${_currentResults.length})',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.blackText,
            ),
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _currentResults.length,
            itemBuilder: (context, index) {
              return _buildRecipeCard(_currentResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(recipe: recipe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
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
            // Recipe image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder for image
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 48,
                          color: AppColors.successGreen.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe['name'],
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 12,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: AppColors.grayText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Recipe details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe name
                  Text(
                    recipe['name'],
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    recipe['description'],
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      color: AppColors.grayText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Recipe meta info
                  Row(
                    children: [
                      _buildMetaChip(Icons.local_fire_department, recipe['calories'], AppColors.primaryAccent),
                      const SizedBox(width: 12),
                      _buildMetaChip(Icons.access_time, recipe['prepTime'], AppColors.successGreen),
                      const SizedBox(width: 12),
                      _buildMetaChip(Icons.star_outline, recipe['difficulty'], AppColors.purpleAccent),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (recipe['tags'] as List<String>)
                        .map((tag) => _buildTag(tag))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.grayText,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}