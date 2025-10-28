import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../models/recipe.dart';
import '../../../services/recipe_service.dart';
import '../../../services/cloudinary_service.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe? recipe; // null for add, Recipe for edit

  const EditRecipePage({
    super.key,
    this.recipe,
  });

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _recipeService = RecipeService();
  final _cloudinaryService = CloudinaryService();
  final _imagePicker = ImagePicker();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructionsController;
  late TextEditingController _funFactController;
  late TextEditingController _prepTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _kcalController;
  late TextEditingController _averagePriceController; // Average price in PHP

  // Image
  String? _imageUrl;
  File? _selectedImageFile;
  bool _isUploadingImage = false;

  // Ingredients
  List<Map<String, TextEditingController>> _ingredients = [];

  // Difficulty
  String _selectedDifficulty = 'Easy';
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  // Health Conditions
  Map<String, bool> _healthConditions = {
    'Diabetes': false,
    'Hypertension': false,
    'Obesity/Overweight': false,
    'Underweight/Malnutrition': false,
    'Heart Disease/High Cholesterol': false,
    'Anemia': false,
    'Osteoporosis': false,
    'None (Healthy)': false,
  };

  // Meal Timing
  Map<String, bool> _mealTiming = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
    'Snack': false,
  };

  // Tags
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final recipe = widget.recipe;

    _nameController = TextEditingController(text: recipe?.recipeName ?? '');
    _descriptionController = TextEditingController(text: recipe?.description ?? '');
    _instructionsController = TextEditingController(text: recipe?.cookingInstructions ?? '');
    _funFactController = TextEditingController(text: recipe?.funFact ?? '');
    _prepTimeController = TextEditingController(text: recipe?.prepTimeMinutes.toString() ?? '');
    _servingsController = TextEditingController(text: recipe?.baseServings.toString() ?? '');
    _kcalController = TextEditingController(text: recipe?.kcal.toString() ?? '');
    _averagePriceController = TextEditingController(
      text: recipe?.averagePrice != null ? recipe!.averagePrice!.toStringAsFixed(2) : '',
    );

    _imageUrl = recipe?.imageUrl;
    _selectedDifficulty = recipe?.difficulty ?? 'Easy';

    // Initialize ingredients
    if (recipe != null && recipe.ingredients.isNotEmpty) {
      _ingredients = recipe.ingredients.map((ing) {
        return {
          'name': TextEditingController(text: ing.ingredientName),
          'quantity': TextEditingController(text: ing.quantity.toString()),
          'unit': TextEditingController(text: ing.unit),
        };
      }).toList();
    } else {
      _addIngredientField();
    }

    // Initialize health conditions
    if (recipe != null) {
      _healthConditions = {
        'Diabetes': recipe.healthConditions.diabetes,
        'Hypertension': recipe.healthConditions.hypertension,
        'Obesity/Overweight': recipe.healthConditions.obesityOverweight,
        'Underweight/Malnutrition': recipe.healthConditions.underweightMalnutrition,
        'Heart Disease/High Cholesterol': recipe.healthConditions.heartDiseaseChol,
        'Anemia': recipe.healthConditions.anemia,
        'Osteoporosis': recipe.healthConditions.osteoporosis,
        'None (Healthy)': recipe.healthConditions.none,
      };
    }

    // Initialize meal timing
    if (recipe != null) {
      _mealTiming = {
        'Breakfast': recipe.mealTiming.breakfast,
        'Lunch': recipe.mealTiming.lunch,
        'Dinner': recipe.mealTiming.dinner,
        'Snack': recipe.mealTiming.snack,
      };
    }

    // Initialize tags
    _tags = recipe?.tags ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _funFactController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    _kcalController.dispose();
    _averagePriceController.dispose();
    _tagController.dispose();
    for (var ing in _ingredients) {
      ing['name']?.dispose();
      ing['quantity']?.dispose();
      ing['unit']?.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredients.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(),
        'unit': TextEditingController(),
      });
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients[index]['name']?.dispose();
        _ingredients[index]['quantity']?.dispose();
        _ingredients[index]['unit']?.dispose();
        _ingredients.removeAt(index);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
        _isUploadingImage = true;
      });

      try {
        final uploadedUrl = await _cloudinaryService.uploadImage(_selectedImageFile!);
        setState(() {
          _imageUrl = uploadedUrl;
          _isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _isUploadingImage = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed: $e')),
          );
        }
      }
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_imageUrl == null || _imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipe image')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare ingredients
      final ingredients = _ingredients.map((ing) {
        return RecipeIngredient(
          ingredientName: ing['name']!.text.trim(),
          quantity: double.tryParse(ing['quantity']!.text.trim()) ?? 0,
          unit: ing['unit']!.text.trim(),
        );
      }).toList();

      // Prepare health conditions
      final healthConditions = RecipeHealthConditions(
        diabetes: _healthConditions['Diabetes'] ?? false,
        hypertension: _healthConditions['Hypertension'] ?? false,
        obesityOverweight: _healthConditions['Obesity/Overweight'] ?? false,
        underweightMalnutrition: _healthConditions['Underweight/Malnutrition'] ?? false,
        heartDiseaseChol: _healthConditions['Heart Disease/High Cholesterol'] ?? false,
        anemia: _healthConditions['Anemia'] ?? false,
        osteoporosis: _healthConditions['Osteoporosis'] ?? false,
        none: _healthConditions['None (Healthy)'] ?? false,
      );

      // Prepare meal timing
      final mealTiming = RecipeMealTiming(
        breakfast: _mealTiming['Breakfast'] ?? false,
        lunch: _mealTiming['Lunch'] ?? false,
        dinner: _mealTiming['Dinner'] ?? false,
        snack: _mealTiming['Snack'] ?? false,
      );

      // Parse average price (optional)
      double? averagePrice;
      final priceText = _averagePriceController.text.trim();
      if (priceText.isNotEmpty) {
        averagePrice = double.tryParse(priceText);
      }

      // Create recipe object
      final recipe = Recipe(
        id: widget.recipe?.id ?? '',
        recipeName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrl!,
        kcal: int.tryParse(_kcalController.text.trim()) ?? 0,
        baseServings: int.tryParse(_servingsController.text.trim()) ?? 1,
        cookingInstructions: _instructionsController.text.trim(),
        difficulty: _selectedDifficulty,
        prepTimeMinutes: int.tryParse(_prepTimeController.text.trim()) ?? 0,
        funFact: _funFactController.text.trim(),
        ingredients: ingredients,
        tags: _tags,
        healthConditions: healthConditions,
        mealTiming: mealTiming,
        averagePrice: averagePrice, // Add average price
        createdAt: widget.recipe?.createdAt ?? DateTime.now(),
      );

      // Save to Firebase
      String? result;
      if (widget.recipe != null) {
        // Update existing recipe
        final success = await _recipeService.updateRecipe(recipe.id, recipe);
        result = success ? 'success' : null;
      } else {
        // Add new recipe
        result = await _recipeService.addRecipe(recipe);
      }

      setState(() {
        _isSaving = false;
      });

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recipe != null ? 'Recipe updated successfully' : 'Recipe added successfully'),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save recipe')),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.successGreen,
            elevation: 0,
            title: Text(
              isEditing ? 'Edit Recipe' : 'Add Recipe',
              style: const TextStyle(
                fontFamily: AppConstants.headingFont,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_isSaving)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: _saveRecipe,
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Image display
                                if (_selectedImageFile != null)
                                  Image.file(
                                    _selectedImageFile!,
                                    fit: BoxFit.cover,
                                  )
                                else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                                  Image.network(
                                    _imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppColors.successGreen.withOpacity(0.2),
                                      child: const Icon(
                                        Icons.add_photo_alternate,
                                        size: 60,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    color: AppColors.successGreen.withOpacity(0.3),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 60,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to select image',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontFamily: AppConstants.primaryFont,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Upload progress overlay
                                if (_isUploadingImage)
                                  Container(
                                    color: Colors.black54,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ),

                                // Edit icon overlay
                                if (_imageUrl != null || _selectedImageFile != null)
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.successGreen,
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Basic Information Section
                    _buildSection(
                      'Basic Information',
                      Icons.info_outline,
                      [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Recipe Name',
                          hint: 'e.g., Chicken Adobo',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter recipe name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Brief description of the recipe',
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _prepTimeController,
                                label: 'Prep Time (min)',
                                hint: '40',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _servingsController,
                                label: 'Servings',
                                hint: '4',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _kcalController,
                                label: 'Calories',
                                hint: '270',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _averagePriceController,
                          label: 'Average Price (₱)',
                          hint: 'Enter average cost in PHP (e.g., 150.00)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            // Optional field, but if provided must be valid
                            if (value != null && value.trim().isNotEmpty) {
                              final price = double.tryParse(value.trim());
                              if (price == null || price < 0) {
                                return 'Please enter a valid price';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'Difficulty',
                          value: _selectedDifficulty,
                          items: _difficulties,
                          onChanged: (value) {
                            setState(() {
                              _selectedDifficulty = value!;
                            });
                          },
                        ),
                      ],
                    ),

                    // Ingredients Section
                    _buildSection(
                      'Ingredients',
                      Icons.shopping_cart_outlined,
                      [
                        ..._ingredients.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ing = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildTextField(
                                    controller: ing['name']!,
                                    label: 'Ingredient',
                                    hint: 'e.g., Chicken',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                    controller: ing['quantity']!,
                                    label: 'Quantity',
                                    hint: '1.5',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                    controller: ing['unit']!,
                                    label: 'Unit',
                                    hint: 'cups',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    _ingredients.length > 1 ? Icons.remove_circle : Icons.add_circle,
                                    color: _ingredients.length > 1 ? Colors.red : AppColors.successGreen,
                                  ),
                                  onPressed: () {
                                    if (_ingredients.length > 1) {
                                      _removeIngredientField(index);
                                    } else if (index == _ingredients.length - 1) {
                                      _addIngredientField();
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        if (_ingredients.length > 1)
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Ingredient'),
                            onPressed: _addIngredientField,
                          ),
                      ],
                    ),

                    // Cooking Instructions Section
                    _buildSection(
                      'Cooking Instructions',
                      Icons.restaurant_menu,
                      [
                        _buildTextField(
                          controller: _instructionsController,
                          label: 'Instructions',
                          hint: 'Step-by-step cooking instructions...',
                          maxLines: 8,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter cooking instructions';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    // Fun Fact Section
                    _buildSection(
                      'Fun Fact (Optional)',
                      Icons.lightbulb_outline,
                      [
                        _buildTextField(
                          controller: _funFactController,
                          label: 'Fun Fact',
                          hint: 'Interesting fact about this recipe...',
                          maxLines: 3,
                        ),
                      ],
                    ),

                    // Health Conditions Section
                    _buildSection(
                      'Suitable For',
                      Icons.health_and_safety,
                      [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _healthConditions.keys.map((condition) {
                            return FilterChip(
                              label: Text(condition),
                              selected: _healthConditions[condition]!,
                              onSelected: (selected) {
                                setState(() {
                                  _healthConditions[condition] = selected;
                                });
                              },
                              selectedColor: AppColors.successGreen.withOpacity(0.3),
                              checkmarkColor: AppColors.successGreen,
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    // Meal Timing Section
                    _buildSection(
                      'Meal Timing',
                      Icons.schedule,
                      [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _mealTiming.keys.map((timing) {
                            return FilterChip(
                              label: Text(timing),
                              selected: _mealTiming[timing]!,
                              onSelected: (selected) {
                                setState(() {
                                  _mealTiming[timing] = selected;
                                });
                              },
                              selectedColor: AppColors.primaryAccent.withOpacity(0.3),
                              checkmarkColor: AppColors.primaryAccent,
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    // Tags Section
                    _buildSection(
                      'Tags',
                      Icons.label_outline,
                      [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagController,
                                decoration: InputDecoration(
                                  hintText: 'Add a tag',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addTag,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                        if (_tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _tags.asMap().entries.map((entry) {
                              final index = entry.key;
                              final tag = entry.value;
                              return Chip(
                                label: Text(tag),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _removeTag(index),
                                backgroundColor: Colors.blue.withOpacity(0.1),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveRecipe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEditing ? 'Update Recipe' : 'Add Recipe',
                                  style: const TextStyle(
                                    fontFamily: AppConstants.headingFont,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.successGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
