import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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

  // Sample answers data (will be replaced with Firebase data later)
  late List<Map<String, dynamic>> _sampleAnswers;

  @override
  void initState() {
    super.initState();
    // Initialize sample answers based on the question
    _sampleAnswers = [
      {
        'id': '1',
        'answerId': 'ans_1',
        'userName': 'Maria Santos',
        'userAvatar': 'MS',
        'timeAgo': '2 hrs ago',
        'answerText': 'It\'s important to focus on a diet that\'s low in sodium. You should also eat plenty of fruits, vegetables, and whole grains.',
        'isVerifiedUser': true,
        'isNutritionist': true,
        'likes': 15,
        'isLiked': false,
      },
      {
        'id': '2',
        'answerId': 'ans_2',
        'userName': 'Juan Dela Cruz',
        'userAvatar': 'JD',
        'timeAgo': '1 hr ago',
        'answerText': 'I suggest following the DASH diet. It\'s specifically designed to help lower blood pressure through a focus on healthy eating.',
        'isVerifiedUser': false,
        'isNutritionist': false,
        'likes': 8,
        'isLiked': true,
      },
    ];
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
                              // Answers header
                              _buildAnswersHeader(),
                              const SizedBox(height: 16),
                              // Answers list
                              ..._sampleAnswers.map((answer) => 
                                _buildAnswerCard(answer)
                              ).toList(),
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
                    widget.question['userAvatar'] ?? 'U',
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
                    Text(
                      widget.question['userName'] ?? 'Anonymous',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    Text(
                      widget.question['timeAgo'] ?? '',
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
            widget.question['questionText'] ?? '',
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

  Widget _buildAnswersHeader() {
    return Row(
      children: [
        Text(
          '${_sampleAnswers.length} Answers',
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
        border: answer['isNutritionist'] == true
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
                    answer['userAvatar'] ?? 'U',
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
                          answer['userName'] ?? 'Anonymous',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackText,
                          ),
                        ),
                        if (answer['isNutritionist'] == true) ...[
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
                      answer['timeAgo'] ?? '',
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
            answer['answerText'] ?? '',
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
              // Like button
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (answer['isLiked'] == true) {
                      answer['likes'] = (answer['likes'] ?? 0) - 1;
                      answer['isLiked'] = false;
                    } else {
                      answer['likes'] = (answer['likes'] ?? 0) + 1;
                      answer['isLiked'] = true;
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      answer['isLiked'] == true
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 16,
                      color: answer['isLiked'] == true
                          ? AppColors.successGreen
                          : AppColors.grayText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${answer['likes'] ?? 0}',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: answer['isLiked'] == true
                            ? AppColors.successGreen
                            : AppColors.grayText,
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
              onTap: () {
                if (_answerController.text.trim().isNotEmpty) {
                  // TODO: Post answer to Firebase
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
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
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