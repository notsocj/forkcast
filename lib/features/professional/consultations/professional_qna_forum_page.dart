import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/qna_service.dart';
import '../../qna/qna_answers_page.dart';

class ProfessionalQnAForumPage extends StatefulWidget {
  const ProfessionalQnAForumPage({super.key});

  @override
  State<ProfessionalQnAForumPage> createState() => _ProfessionalQnAForumPageState();
}

class _ProfessionalQnAForumPageState extends State<ProfessionalQnAForumPage> {
  final QnAService _qnaService = QnAService();
  final TextEditingController _searchController = TextEditingController();
  String _viewMode = 'all'; // 'all' or 'saved'
  Map<String, bool> _savedQuestions = {};

  @override
  void initState() {
    super.initState();
    _loadSavedQuestions();
  }

  Future<void> _loadSavedQuestions() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final savedQuestions = await _qnaService.getSavedQuestions().first;
      setState(() {
        _savedQuestions = {
          for (var question in savedQuestions) question['id'] as String: true
        };
      });
    } catch (e) {
      print('Error loading saved questions: $e');
    }
  }

  Future<void> _toggleSaveQuestion(String questionId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final isSaved = _savedQuestions[questionId] ?? false;
      
      if (isSaved) {
        await _qnaService.unsaveQuestion(questionId);
        setState(() {
          _savedQuestions[questionId] = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question removed from saved'),
              backgroundColor: AppColors.grayText,
              duration: Duration(seconds: 2),
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
            const SnackBar(
              content: Text('Question saved successfully'),
              backgroundColor: AppColors.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Delete Question?'),
            ],
          ),
          content: const Text(
            'This will permanently delete the question and all its answers. This action cannot be undone.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _qnaService.deleteQuestion(questionId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question deleted successfully'),
              backgroundColor: AppColors.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPostQuestionDialog() {
    final TextEditingController questionController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ask a Question',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.grayText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your nutrition question here...',
                hintStyle: const TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.grayText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grayText),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.successGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (questionController.text.trim().isNotEmpty) {
                    try {
                      await _qnaService.postQuestion(questionText: questionController.text.trim());
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Question posted successfully!'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error posting question: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Post Question',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          // Professional Q&A Header
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppColors.successGreen,
            elevation: 0,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.successGreen, Color(0xFF7CB577)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Q&A Forum 🩺',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _viewMode = _viewMode == 'all' ? 'saved' : 'all';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _viewMode == 'saved' 
                                      ? AppColors.white 
                                      : AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _viewMode == 'saved' 
                                          ? Icons.bookmark 
                                          : Icons.bookmark_border,
                                      color: _viewMode == 'saved' 
                                          ? AppColors.successGreen 
                                          : AppColors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _viewMode == 'saved' ? 'Showing Saved' : 'Saved',
                                      style: TextStyle(
                                        fontFamily: 'OpenSans',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _viewMode == 'saved' 
                                            ? AppColors.successGreen 
                                            : AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search questions...',
                              hintStyle: const TextStyle(
                                fontFamily: 'OpenSans',
                                color: AppColors.grayText,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(Icons.search, color: AppColors.grayText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Ask Question Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _showPostQuestionDialog,
                child: Container(
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
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.successGreen.withOpacity(0.2),
                        child: const Icon(
                          Icons.medical_services,
                          color: AppColors.successGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ask a nutrition question...',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            color: AppColors.grayText,
                          ),
                        ),
                      ),
                      const Icon(Icons.edit, color: AppColors.successGreen, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Questions List
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _viewMode == 'all' 
                ? _qnaService.getAllQuestions()
                : _qnaService.getSavedQuestions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.successGreen),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final questions = snapshot.data ?? [];

              if (questions.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _viewMode == 'saved' ? Icons.bookmark_border : Icons.help_outline,
                          size: 80,
                          color: AppColors.grayText.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _viewMode == 'saved' 
                              ? 'No saved questions yet'
                              : 'No questions yet',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grayText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _viewMode == 'saved'
                              ? 'Save questions to view them here'
                              : 'Be the first to ask a question!',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            color: AppColors.grayText.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final question = questions[index];
                      final isSaved = _savedQuestions[question['id']] ?? false;
                      final isOwner = userId == question['user_id'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QnaAnswersPage(question: question),
                              ),
                            );
                          },
                          child: Container(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.successGreen.withOpacity(0.2),
                                      child: Text(
                                        (question['user_name'] ?? 'A')[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.successGreen,
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
                                              Flexible(
                                                child: Text(
                                                  question['user_name'] ?? 'Anonymous',
                                                  style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (question['user_specialization'] != null && (question['user_specialization'] as String).isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.successGreen.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.verified, size: 12, color: AppColors.successGreen),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Nutritionist',
                                                        style: TextStyle(
                                                          fontFamily: 'OpenSans',
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppColors.successGreen,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            _formatTimeAgo(question['posted_at'] as DateTime),
                                            style: TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontSize: 12,
                                              color: AppColors.grayText.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isOwner)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20),
                                            color: Colors.red,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _deleteQuestion(question['id'] as String),
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                                            size: 20,
                                          ),
                                          color: isSaved ? AppColors.successGreen : AppColors.grayText,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () => _toggleSaveQuestion(question['id'] as String),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  question['question_text'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.comment_outlined,
                                        size: 16,
                                        color: AppColors.successGreen,
                                      ),
                                      const SizedBox(width: 6),
                                      FutureBuilder<int>(
                                        future: _qnaService.getAnswersCount(question['id'] as String),
                                        builder: (context, snapshot) {
                                          final count = snapshot.data ?? question['answers_count'] ?? 0;
                                          return Text(
                                            '$count ${count == 1 ? 'answer' : 'answers'}',
                                            style: const TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.successGreen,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: questions.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
