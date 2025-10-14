import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../services/qna_service.dart';
import 'qna_answers_page.dart';

class QnaForumPage extends StatefulWidget {
  const QnaForumPage({super.key});

  @override
  State<QnaForumPage> createState() => _QnaForumPageState();
}

class _QnaForumPageState extends State<QnaForumPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final QnAService _qnaService = QnAService();

  // Track loading state
  bool _isPostingQuestion = false;
  
  // Track saved questions
  final Map<String, bool> _savedQuestions = {};
  
  // Track current user ID
  String? _currentUserId;
  
  // Track view mode: 'all' or 'saved'
  String _viewMode = 'all';
  
  // Track search query
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search and saved button
            _buildHeader(),
            // Main content area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Refresh Q&A data
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: AppColors.successGreen,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Ask question input
                              _buildAskQuestionSection(),
                              const SizedBox(height: 24),
                              // Questions list from Firebase - Dynamic based on view mode
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _viewMode == 'all' 
                                    ? _qnaService.getAllQuestions()
                                    : _qnaService.getSavedQuestions(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.successGreen,
                                      ),
                                    );
                                  }
                                  
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        'Error loading questions: ${snapshot.error}',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                    );
                                  }
                                  
                                  final questions = snapshot.data ?? [];
                                  
                                  // Filter questions based on search query
                                  final query = _searchQuery.toLowerCase();
                                  final filteredQuestions = query.isEmpty
                                      ? questions
                                      : questions.where((question) {
                                          final questionText = (question['question_text'] ?? '').toString().toLowerCase();
                                          final userName = (question['user_name'] ?? '').toString().toLowerCase();
                                          final specialization = (question['user_specialization'] ?? '').toString().toLowerCase();
                                          final tags = (question['tags'] as List<dynamic>?) ?? const [];
                                          final matchesTag = tags.any((tag) => tag.toString().toLowerCase().contains(query));
                                          
                                          return questionText.contains(query) || 
                                                 userName.contains(query) || 
                                                 specialization.contains(query) || 
                                                 matchesTag;
                                        }).toList();
                                  
                                  if (filteredQuestions.isEmpty) {
                                    return Center(
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 40),
                                          Icon(
                                            query.isEmpty
                                                ? (_viewMode == 'saved' 
                                                    ? Icons.bookmark_border 
                                                    : Icons.help_outline)
                                                : Icons.search_off,
                                            size: 64,
                                            color: AppColors.grayText,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            query.isEmpty
                                                ? (_viewMode == 'saved' 
                                                    ? 'No saved questions yet'
                                                    : 'No questions yet')
                                                : 'No questions found',
                                            style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.blackText,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            query.isEmpty
                                                ? (_viewMode == 'saved'
                                                    ? 'Save questions to view them here'
                                                    : 'Be the first to ask a question!')
                                                : 'Try a different search term',
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
                                  
                                  return Column(
                                    children: filteredQuestions.map((question) => 
                                      _buildQuestionCard(question)
                                    ).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                child: Icon(
                  Icons.forum,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q&A Forum',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ask questions and get expert advice from nutritionists',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Enhanced Search Bar and Saved Button
          Row(
            children: [
              // Search bar with improved visibility
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: AppColors.white.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search questions...',
                      hintStyle: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        color: AppColors.grayText.withOpacity(0.7),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.search,
                          color: AppColors.successGreen,
                          size: 24,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.clear,
                                  color: AppColors.grayText,
                                  size: 20,
                                ),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Enhanced Saved button - Functional
              GestureDetector(
                onTap: () {
                  setState(() {
                    _viewMode = _viewMode == 'all' ? 'saved' : 'all';
                  });
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: _viewMode == 'saved' ? AppColors.successGreen : AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _viewMode == 'saved' 
                          ? AppColors.successGreen 
                          : AppColors.white.withOpacity(0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _viewMode == 'saved' ? Icons.bookmark : Icons.bookmark_border,
                        color: _viewMode == 'saved' ? AppColors.white : AppColors.successGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _viewMode == 'saved' ? 'Showing Saved' : 'Saved',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _viewMode == 'saved' ? AppColors.white : AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAskQuestionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          // User avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'U', // Will be replaced with actual user initials
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Ask question input
          Expanded(
            child: GestureDetector(
              onTap: () {
                _showAskQuestionDialog();
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.grayText.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Ask question...',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    // Debug: Print question data to verify Firebase fields
    print('Forum question data: $question');
    
    // Helper function to format posted time
    String getTimeAgo(question) {
      final postedAt = question['posted_at'];
      if (postedAt == null) return '';
      
      final now = DateTime.now();
      final posted = (postedAt is Timestamp) 
          ? postedAt.toDate() 
          : DateTime.tryParse(postedAt.toString()) ?? now;
      final difference = now.difference(posted);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    }

    // Get user initials for avatar
    String getUserInitials(String? userName) {
      if (userName == null || userName.isEmpty) return 'U';
      final parts = userName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return userName[0].toUpperCase();
    }

    final isNutritionist = (question['user_specialization'] ?? '').toLowerCase().contains('nutritionist');
    
    return GestureDetector(
      onTap: () {
        // Navigate to answers page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QnaAnswersPage(question: question),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: isNutritionist
              ? Border.all(
                  color: AppColors.successGreen.withOpacity(0.3),
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Row(
              children: [
                // User avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      getUserInitials(question['user_name']),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            question['user_name'] ?? 'Anonymous',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackText,
                            ),
                          ),
                          if (isNutritionist) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Certified Nutritionist',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        getTimeAgo(question),
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 12,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Question text
            Text(
              question['question_text'] ?? '',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.blackText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Action row
            Row(
              children: [
                // Answers count
                Row(
                  children: [
                    Icon(
                      Icons.comment,
                      size: 20,
                      color: AppColors.grayText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${question['answers_count'] ?? 0} Answers',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Save button (functional)
                FutureBuilder<bool>(
                  future: _qnaService.isQuestionSaved(question['id'] ?? ''),
                  builder: (context, snapshot) {
                    final isSaved = _savedQuestions[question['id']] ?? snapshot.data ?? false;
                    return GestureDetector(
                      onTap: () => _toggleSaveQuestion(question['id'] ?? '', isSaved),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            size: 20,
                            color: isSaved ? AppColors.successGreen : AppColors.grayText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSaved ? 'Saved' : 'Save',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 12,
                              color: isSaved ? AppColors.successGreen : AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Delete button (only for owned questions)
                if (question['user_id'] == _currentUserId) ...[
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showDeleteQuestionDialog(question['id'] ?? ''),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Post a new question to Firebase
  Future<void> _postQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a question',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: AppColors.white,
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isPostingQuestion = true;
    });

    try {
      await _qnaService.postQuestion(
        questionText: _questionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        _questionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Question posted successfully!',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.white,
              ),
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to post question: $e',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPostingQuestion = false;
        });
      }
    }
  }

  /// Toggle save/unsave question
  Future<void> _toggleSaveQuestion(String questionId, bool currentlySaved) async {
    try {
      if (currentlySaved) {
        await _qnaService.unsaveQuestion(questionId);
        setState(() {
          _savedQuestions[questionId] = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Question removed from saved',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.grayText,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        await _qnaService.saveQuestion(questionId);
        setState(() {
          _savedQuestions[questionId] = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Question saved!',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.white,
                ),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save question: $e',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show delete question confirmation dialog
  void _showDeleteQuestionDialog(String questionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Question',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this question? This will also delete all answers. This action cannot be undone.',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: AppColors.grayText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.grayText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteQuestion(questionId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Delete a question
  Future<void> _deleteQuestion(String questionId) async {
    try {
      await _qnaService.deleteQuestion(questionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Question deleted successfully',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.white,
              ),
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete question: $e',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: AppColors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAskQuestionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grayText.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Ask a Question',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                ),
                const SizedBox(height: 16),
                // Question input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grayText.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _questionController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        color: AppColors.blackText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What would you like to ask our nutrition experts?',
                        hintStyle: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          color: AppColors.grayText,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Post button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isPostingQuestion ? null : () => _postQuestion(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isPostingQuestion
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Post Question',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}