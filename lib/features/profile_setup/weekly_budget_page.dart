import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants.dart';
import '../../core/widgets/progress_pill.dart';
import '../../providers/profile_setup_provider.dart';
import 'household_size_page.dart';

class WeeklyBudgetPage extends StatefulWidget {
  const WeeklyBudgetPage({super.key});

  @override
  State<WeeklyBudgetPage> createState() => _WeeklyBudgetPageState();
}

class _WeeklyBudgetPageState extends State<WeeklyBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  
  // Minimum allowed weekly budget (PHP)
  static const int _minBudget = 500;
  
  // Budget selection state
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    _budgetController.addListener(_updateContinueButton);
  }

  @override
  void dispose() {
    _budgetController.removeListener(_updateContinueButton);
    _budgetController.dispose();
    super.dispose();
  }

  void _updateContinueButton() {
    setState(() {
      final text = _budgetController.text.trim();
      if (text.isEmpty) {
        _canContinue = false;
      } else {
        final val = int.tryParse(text) ?? 0;
        _canContinue = val >= _minBudget;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.blackText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ProgressPill(current: 6, total: 8, width: 200),
            const SizedBox(width: 12),
            const Text(
              '6/8',
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 14,
                color: AppColors.blackText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Top spacing and title
                const SizedBox(height: 40),
                Text(
                  "Select your preferred\nweekly budget.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Budget selection section
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Modern budget input card
                        Container(
                          width: 320,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.successGreen.withOpacity(0.18), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.successGreen.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Decrement
                              IconButton(
                                onPressed: () {
                                  final cur = double.tryParse(_budgetController.text) ?? 0;
                                  final next = (cur - 50).clamp(_minBudget.toDouble(), 1000000);
                                  _budgetController.text = (next.round()).toString();
                                  _updateContinueButton();
                                },
                                icon: Icon(Icons.remove_circle_outline, color: AppColors.primaryAccent),
                              ),
                              const SizedBox(width: 8),
                              // Numeric display / input
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    // Show a custom-styled dialog that follows the app palette
                                    await showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        final tmpController = TextEditingController(text: _budgetController.text);
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBackground,
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.12),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Enter weekly budget',
                                                        style: TextStyle(
                                                          fontFamily: AppConstants.headingFont,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.blackText,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () => Navigator.pop(ctx),
                                                      icon: Icon(Icons.close, color: AppColors.grayText),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: AppColors.successGreen.withOpacity(0.18)),
                                                  ),
                                                  child: TextField(
                                                    controller: tmpController,
                                                    keyboardType: TextInputType.number,
                                                    decoration: InputDecoration(
                                                      // removed peso prefix to avoid missing-glyph rendering issues
                                                      hintText: 'e.g. 1500',
                                                      hintStyle: TextStyle(color: AppColors.grayText),
                                                      border: InputBorder.none,
                                                    ),
                                                    style: TextStyle(
                                                      fontFamily: AppConstants.primaryFont,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.blackText,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(ctx),
                                                      child: Text('Cancel', style: TextStyle(color: AppColors.grayText)),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.successGreen,
                                                      ),
                                                      onPressed: () {
                                                        _budgetController.text = tmpController.text.trim();
                                                        Navigator.pop(ctx);
                                                        _updateContinueButton();
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // removed small peso glyph (was rendering as '?')
                                      const SizedBox(height: 4),
                                      Text(
                                        _budgetController.text.isEmpty ? 'Enter amount' : _budgetController.text,
                                        style: TextStyle(
                                          fontFamily: AppConstants.primaryFont,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blackText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Increment
                              IconButton(
                                onPressed: () {
                                  final cur = double.tryParse(_budgetController.text) ?? 0;
                                  final next = (cur + 50).clamp(_minBudget.toDouble(), 1000000);
                                  _budgetController.text = (next.round()).toString();
                                  _updateContinueButton();
                                },
                                icon: Icon(Icons.add_circle_outline, color: AppColors.primaryAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Continue Button removed from body; pinned version will be added as bottomNavigationBar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canContinue ? _handleContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 2,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    String budgetValue = _budgetController.text.trim();
    
    if (budgetValue.isNotEmpty) {
      // Save weekly budget to profile setup provider
      final profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);
      final budget = int.tryParse(budgetValue) ?? 0;
      // Enforce minimum budget
      if (budget < _minBudget) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Weekly budget must be at least ₱$_minBudget')),
        );
        return;
      }
      // For now, using the same value for min and max, but this could be enhanced
      // to allow separate min/max inputs in the future
      profileProvider.setWeeklyBudget(budget, budget);

      // Navigate to household size page
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const HouseholdSizePage())
      );
    }
  }
}