import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/recipe.dart';
import '../../data/predefined_meals.dart';
import '../../services/recipe_service.dart';
import '../../services/search_history_service.dart';
import 'recipe_detail_page.dart';

class MealSearchResultsPage extends StatefulWidget {
  final String searchQuery;
  final List<String>? mealTypes;
  final String? prepTimeRange;
  final List<String>? mainIngredients;
  final List<String>? healthConditions;
  
  const MealSearchResultsPage({
    super.key,
    required this.searchQuery,
    this.mealTypes,
    this.prepTimeRange,
    this.mainIngredients,
    this.healthConditions,
  });

  @override
  State<MealSearchResultsPage> createState() => _MealSearchResultsPageState();
}

class _MealSearchResultsPageState extends State<MealSearchResultsPage> {
  late TextEditingController _searchController;
  final RecipeService _recipeService = RecipeService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  
  List<Recipe> _searchResults = [];
  List<Recipe> _currentResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  // Filter state
  List<String> _selectedMealTypes = [];
  String? _selectedPrepTimeRange;
  List<String> _selectedMainIngredients = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    
    // Initialize filters from widget parameters
    _selectedMealTypes = widget.mealTypes ?? [];
    _selectedPrepTimeRange = widget.prepTimeRange;
    _selectedMainIngredients = widget.mainIngredients ?? [];
    
    _performSearch(widget.searchQuery);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    try {
      // Add to search history if query is not empty
      if (query.trim().isNotEmpty) {
        await _searchHistoryService.addSearchToHistory(query.trim());
      }

      // Perform Firebase search with filters
      final results = await _recipeService.searchRecipes(
        query,
        healthConditions: widget.healthConditions,
        mealTypes: _selectedMealTypes.isNotEmpty ? _selectedMealTypes : null,
        prepTimeRange: _selectedPrepTimeRange,
        mainIngredients: _selectedMainIngredients.isNotEmpty ? _selectedMainIngredients : null,
      );

      setState(() {
        _searchResults = results;
        _currentResults = results;
        _isLoading = false;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _currentResults = [];
        _isLoading = false;
        _isSearching = false;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching recipes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            // Filters section
            if (_showFilters) _buildFiltersSection(),
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
                child: _isLoading 
                    ? _buildLoadingView()
                    : _currentResults.isEmpty
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
          GestureDetector(
            onTap: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _showFilters 
                    ? AppColors.white.withOpacity(0.3)
                    : AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.successGreen),
            ),
            SizedBox(height: 24),
            Text(
              'Searching recipes...',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Type Filter
          _buildFilterSection(
            'Meal Type',
            ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
            _selectedMealTypes,
            (selected) {
              setState(() {
                _selectedMealTypes = selected;
              });
              _performSearch(_searchController.text);
            },
          ),
          const SizedBox(height: 16),
          
          // Prep Time Filter
          _buildSingleSelectFilter(
            'Prep Time',
            ['Under 20 mins', '15–30 min', '30–60 min', 'Over 1 hour'],
            _selectedPrepTimeRange,
            (selected) {
              setState(() {
                _selectedPrepTimeRange = selected;
              });
              _performSearch(_searchController.text);
            },
          ),
          const SizedBox(height: 16),
          
          // Main Ingredient Filter
          _buildFilterSection(
            'Main Ingredient',
            ['Chicken', 'Pork', 'Beef', 'Fish', 'Vegetable', 'Rice', 'Noodles'],
            _selectedMainIngredients,
            (selected) {
              setState(() {
                _selectedMainIngredients = selected;
              });
              _performSearch(_searchController.text);
            },
          ),
          
          // Clear filters button
          if (_selectedMealTypes.isNotEmpty || 
              _selectedPrepTimeRange != null || 
              _selectedMainIngredients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedMealTypes.clear();
                    _selectedPrepTimeRange = null;
                    _selectedMainIngredients.clear();
                  });
                  _performSearch(_searchController.text);
                },
                child: Text(
                  'Clear All Filters',
                  style: TextStyle(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    List<String> selected,
    Function(List<String>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return GestureDetector(
              onTap: () {
                final newSelected = List<String>.from(selected);
                if (isSelected) {
                  newSelected.remove(option);
                } else {
                  newSelected.add(option);
                }
                onChanged(newSelected);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.white
                      : AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? AppColors.successGreen
                        : AppColors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSingleSelectFilter(
    String title,
    List<String> options,
    String? selected,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () {
                onChanged(isSelected ? null : option);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.white
                      : AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? AppColors.successGreen
                        : AppColors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
          child: RefreshIndicator(
            onRefresh: () async {
              // Refresh the search results
              _performSearch(widget.searchQuery);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.successGreen,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _currentResults.length,
              itemBuilder: (context, index) {
                return _buildRecipeCard(_currentResults[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(meal: _recipeToMeal(recipe)),
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
                  // Recipe image with Cloudinary support
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: recipe.imageUrl.isNotEmpty
                        ? (recipe.imageUrl.startsWith('http://') || recipe.imageUrl.startsWith('https://'))
                            ? Image.network(
                                recipe.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: AppColors.successGreen.withOpacity(0.1),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        color: AppColors.successGreen,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderImage(recipe.recipeName);
                                },
                              )
                            : Image.asset(
                                'assets/images/${recipe.imageUrl}',
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderImage(recipe.recipeName);
                                },
                              )
                        : _buildPlaceholderImage(recipe.recipeName),
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
                    recipe.recipeName,
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
                    recipe.description,
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
                      _buildMetaChip(Icons.local_fire_department, '${recipe.kcal} kcal', AppColors.primaryAccent),
                      const SizedBox(width: 12),
                      _buildMetaChip(Icons.access_time, '${recipe.prepTimeMinutes}min', AppColors.successGreen),
                      const SizedBox(width: 12),
                      _buildMetaChip(Icons.star_outline, recipe.difficulty, AppColors.purpleAccent),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recipe.tags
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

  Widget _buildPlaceholderImage(String recipeName) {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.successGreen.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 48,
              color: AppColors.successGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                recipeName,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  color: AppColors.successGreen,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Convert Recipe to PredefinedMeal for backward compatibility
  PredefinedMeal _recipeToMeal(Recipe recipe) {
    return PredefinedMeal(
      id: recipe.id,
      recipeName: recipe.recipeName,
      description: recipe.description,
      baseServings: recipe.baseServings,
      kcal: recipe.kcal,
      funFact: recipe.funFact,
      ingredients: recipe.ingredients.map((ingredient) => MealIngredient(
        ingredientName: ingredient.ingredientName,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
      )).toList(),
      cookingInstructions: recipe.cookingInstructions,
      healthConditions: HealthConditions(
        diabetes: recipe.healthConditions.diabetes,
        hypertension: recipe.healthConditions.hypertension,
        obesityOverweight: recipe.healthConditions.obesityOverweight,
        underweightMalnutrition: recipe.healthConditions.underweightMalnutrition,
        heartDiseaseChol: recipe.healthConditions.heartDiseaseChol,
        anemia: recipe.healthConditions.anemia,
        osteoporosis: recipe.healthConditions.osteoporosis,
        none: recipe.healthConditions.none,
      ),
      mealTiming: MealTiming(
        breakfast: recipe.mealTiming.breakfast,
        lunch: recipe.mealTiming.lunch,
        dinner: recipe.mealTiming.dinner,
        snack: recipe.mealTiming.snack,
      ),
      tags: recipe.tags,
      difficulty: recipe.difficulty,
      prepTimeMinutes: recipe.prepTimeMinutes,
      imageUrl: recipe.imageUrl,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}