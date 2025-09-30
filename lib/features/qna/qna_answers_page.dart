import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../services/qna_service.dart';

class QnaAnswersPage extends StatefulWidget {
  final Map<String, dynamic> question;

  const QnaAnswersPage({
    super.key,
    required this.question,
  });

  @override
  State<QnaAnswersPage> createState() => _QnaAnswersPageState();
}

class _QnaAnswersPageState extends State<QnaAnswersPage> {
  final TextEditingController _answerController = TextEditingController();
  final QnAService _qnaService = QnAService();
  
  bool _isPostingAnswer = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    // Debug: Print question data to help identify field names
    print('Answers page - Question data: ${widget.question}');
    print('Answers page - user_name: ${widget.question['user_name']}');
    print('Answers page - question_text: ${widget.question['question_text']}');
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
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Refresh answers data
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: AppColors.successGreen,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Original question card
                              _buildQuestionCard(),
                              const SizedBox(height: 24),
                              // Answers list from Firebase
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _qnaService.getAnswersForQuestion(
                                  widget.question['id'] ?? '',
                                ),
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
                                        'Error loading answers: ${snapshot.error}',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                    );
                                  }
                                  
                                  final answers = snapshot.data ?? [];
                                  
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Answers header
                                      _buildAnswersHeader(answers.length),
                                      const SizedBox(height: 16),
                                      // Answers list
                                      if (answers.isEmpty)
                                        Center(
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 40),
                                              Icon(
                                                Icons.chat_bubble_outline,
                                                size: 64,
                                                color: AppColors.grayText,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'No answers yet',
                                                style: TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.blackText,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Be the first to answer this question!',
                                                style: TextStyle(
                                                  fontFamily: 'OpenSans',
                                                  fontSize: 14,
                                                  color: AppColors.grayText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        ...answers.map((answer) => 
                                          _buildAnswerCard(answer)
                                        ).toList(),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 80), // Space for bottom input
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom answer input (fixed at bottom)
            _buildAnswerInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Back button
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
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              'Answers',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          // Share button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.share,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    // Debug: Print the exact question data structure
    print('=== QUESTION CARD DEBUG ===');
    print('Full question data: ${widget.question}');
    print('Keys available: ${widget.question.keys.toList()}');
    print('user_name value: "${widget.question['user_name']}"');
    print('user_name type: ${widget.question['user_name'].runtimeType}');
    print('question_text value: "${widget.question['question_text']}"');
    print('===========================');

    // Helper function to get user initials for avatar
    String getUserInitials(String? userName) {
      if (userName == null || userName.isEmpty || userName == 'null') return 'U';
      final parts = userName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return userName[0].toUpperCase();
    }

    // Helper function to format posted time
    String getTimeAgo() {
      final postedAt = widget.question['posted_at'];
      if (postedAt == null) return '';
      
      final now = DateTime.now();
      final posted = (postedAt is Timestamp) 
          ? postedAt.toDate() 
          : (postedAt is DateTime)
          ? postedAt
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

    // Get the user name with multiple fallback options
    String getUserName() {
      final userName = widget.question['user_name'];
      
      // Handle the case where Firebase returns "Sej Sacdalan" but shows as Anonymous
      if (userName != null && userName.toString().trim().isNotEmpty && userName.toString() != 'null') {
        final cleanName = userName.toString().trim();
        print('Found valid user name: "$cleanName"');
        return cleanName;
      }
      
      print('User name is null/empty, using fallback');
      return 'Anonymous User';
    }

    final displayName = getUserName();
    print('Final display name: "$displayName"');

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    getUserInitials(displayName),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackText,
                          ),
                        ),
                        // Show specialization badge if user is a professional
                        if (widget.question['user_specialization'] != null && 
                            widget.question['user_specialization'].toString() != 'null' &&
                            widget.question['user_specialization'].toString().isNotEmpty) ...[
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
                              widget.question['user_specialization'].toString(),
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
                      getTimeAgo(),
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
          const SizedBox(height: 16),
          // Question text
          Text(
            widget.question['question_text']?.toString() ?? 'No question text available',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              color: AppColors.blackText,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersHeader(int answersCount) {
    return Row(
      children: [
        Text(
          '$answersCount Answers',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        const Spacer(),
        // Sort button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.successGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort,
                size: 16,
                color: AppColors.successGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'Recent',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerCard(Map<String, dynamic> answer) {
    // Helper function to format answered time
    String getTimeAgo(answer) {
      final answeredAt = answer['answered_at'];
      if (answeredAt == null) return '';
      
      final now = DateTime.now();
      final answered = (answeredAt is Timestamp) 
          ? answeredAt.toDate() 
          : DateTime.tryParse(answeredAt.toString()) ?? now;
      final difference = now.difference(answered);
      
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

    final isNutritionist = (answer['expert_specialization'] ?? '').toLowerCase().contains('nutritionist');
    
    return Container(
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
                    getUserInitials(answer['expert_name']),
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
                          answer['expert_name'] ?? 'Anonymous',
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
                      getTimeAgo(answer),
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
          // Answer text
          Text(
            answer['answer_text'] ?? '',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              color: AppColors.blackText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Action row (simplified for Firebase version)
          Row(
            children: [
              // Like button (placeholder - would need additional Firebase structure)
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Like feature coming soon!'),
                      backgroundColor: AppColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: AppColors.grayText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '0',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Reply button
              GestureDetector(
                onTap: () {
                  // Focus on answer input
                  FocusScope.of(context).requestFocus();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: AppColors.grayText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reply',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Delete button (only for owned answers)
              if (answer['expert_id'] == _currentUserId) ...[
                GestureDetector(
                  onTap: () => _showDeleteAnswerDialog(answer['id'] ?? ''),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Report button
              GestureDetector(
                onTap: () {
                  // Show report dialog
                  _showReportDialog();
                },
                child: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
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
                  'U', // Will be replaced with actual user initials
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
            // Answer input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.grayText.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _answerController,
                  maxLines: null,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.blackText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your answer...',
                    hintStyle: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      color: AppColors.grayText,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            GestureDetector(
              onTap: _isPostingAnswer ? null : () => _postAnswer(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isPostingAnswer 
                      ? AppColors.successGreen.withOpacity(0.6)
                      : AppColors.successGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isPostingAnswer
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: AppColors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Post an answer to Firebase
  Future<void> _postAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter an answer',
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
      _isPostingAnswer = true;
    });

    try {
      await _qnaService.postAnswer(
        questionId: widget.question['id'] ?? '',
        answerText: _answerController.text.trim(),
      );

      if (mounted) {
        _answerController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Answer posted successfully!',
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
              'Failed to post answer: $e',
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
          _isPostingAnswer = false;
        });
      }
    }
  }

  /// Show delete answer confirmation dialog
  void _showDeleteAnswerDialog(String answerId) {
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
                'Delete Answer',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this answer? This action cannot be undone.',
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
                await _deleteAnswer(answerId);
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

  /// Delete an answer
  Future<void> _deleteAnswer(String answerId) async {
    try {
      await _qnaService.deleteAnswer(answerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Answer deleted successfully',
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
              'Failed to delete answer: $e',
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

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Report Answer',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          content: Text(
            'Why are you reporting this answer?',
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
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Answer reported successfully',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        color: AppColors.white,
                      ),
                    ),
                    backgroundColor: AppColors.primaryAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Report',
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
}