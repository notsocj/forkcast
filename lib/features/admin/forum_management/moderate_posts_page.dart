import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/forum_management_service.dart';

class ModeratePostsPage extends StatefulWidget {
  const ModeratePostsPage({super.key});

  @override
  State<ModeratePostsPage> createState() => _ModeratePostsPageState();
}

class _ModeratePostsPageState extends State<ModeratePostsPage> {
  String _selectedTab = 'Reported';
  bool _isLoading = true;
  List<Map<String, dynamic>> _reportedContent = [];
  List<Map<String, dynamic>> _recentPosts = [];
  Map<String, dynamic> _stats = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load stats and content concurrently
      final results = await Future.wait([
        ForumManagementService.getModerationStats(),
        ForumManagementService.getReportedContent(status: 'pending'),
        ForumManagementService.getRecentPosts(),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _reportedContent = results[1] as List<Map<String, dynamic>>;
        _recentPosts = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading moderation data: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.successGreen,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Statistics Header
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Reports',
                  _stats['pendingReports']?.toString() ?? '0',
                  Icons.report_problem,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Recent Actions',
                  _stats['recentActions']?.toString() ?? '0',
                  Icons.admin_panel_settings,
                  AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
            
          // Tab Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Reported';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 'Reported' ? AppColors.successGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Reported (${_reportedContent.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 'Reported' ? AppColors.white : AppColors.grayText,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Recent';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 'Recent' ? AppColors.successGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Recent Posts (${_recentPosts.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 'Recent' ? AppColors.white : AppColors.grayText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTab == 'Reported' ? 'Reported Posts' : 'Recent Forum Posts',
                    style: const TextStyle(
                      fontFamily: AppConstants.headingFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackText,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Content Display
                  if (_selectedTab == 'Reported')
                    ..._buildReportedContentList()
                  else
                    ..._buildRecentPostsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppConstants.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReportedContentList() {
    if (_reportedContent.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.successGreen.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.report_outlined,
                size: 64,
                color: AppColors.grayText.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No reported content',
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 16,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reported posts and answers will appear here for review.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return _reportedContent.map((report) => _buildReportCard(report)).toList();
  }

  List<Widget> _buildRecentPostsList() {
    if (_recentPosts.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.successGreen.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.grayText.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No recent posts',
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 16,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Recent forum activity will be displayed here for monitoring.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 14,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return _recentPosts.map((post) => _buildPostCard(post)).toList();
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report['content_type']?.toString().toUpperCase() ?? 'UNKNOWN',
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                ForumManagementService.formatTimeAgo(report['reported_at']),
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report['content_text'] ?? 'No content available',
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.blackText,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: AppColors.grayText,
              ),
              const SizedBox(width: 4),
              Text(
                'Original: ${report['original_author'] ?? 'Unknown'}',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.report_outlined,
                size: 14,
                color: AppColors.grayText,
              ),
              const SizedBox(width: 4),
              Text(
                'By: ${report['reported_by_name'] ?? 'Anonymous'}',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reason: ${report['reason'] ?? 'No reason provided'}',
                    style: const TextStyle(
                      fontFamily: AppConstants.primaryFont,
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleModerationAction(report, 'dismiss'),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Dismiss'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleModerationAction(report, 'hide'),
                  icon: const Icon(Icons.visibility_off, size: 16),
                  label: const Text('Hide'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleModerationAction(report, 'delete'),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (post['type'] ?? 'question').toString().toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                ForumManagementService.formatTimeAgo(post['timestamp']),
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post['type'] == 'question' 
                ? (post['question_text'] ?? 'No content')
                : (post['answer_text'] ?? 'No content'),
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.blackText,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.successGreen.withOpacity(0.2),
                child: Text(
                  _getInitialFromName(post['user_name'] ?? post['expert_name'] ?? 'U'),
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['user_name'] ?? post['expert_name'] ?? 'Anonymous',
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackText,
                      ),
                    ),
                    if ((post['user_specialization'] ?? post['expert_specialization']) != null)
                      Text(
                        post['user_specialization'] ?? post['expert_specialization'],
                        style: const TextStyle(
                          fontFamily: AppConstants.primaryFont,
                          fontSize: 10,
                          color: AppColors.grayText,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'hide') {
                    _hidePost(post);
                  } else if (value == 'delete') {
                    _deletePost(post);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'hide',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Hide Post'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Post'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleModerationAction(Map<String, dynamic> report, String action) async {
    try {
      if (action == 'dismiss') {
        await ForumManagementService.updateReportStatus(
          reportId: report['id'],
          newStatus: 'dismissed',
          adminNotes: 'Report dismissed by admin',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report dismissed successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        await ForumManagementService.moderateContent(
          contentType: report['content_type'],
          contentId: report['content_id'],
          action: action,
          reason: 'Admin moderation action',
        );
        
        await ForumManagementService.updateReportStatus(
          reportId: report['id'],
          newStatus: 'action_taken',
          adminNotes: 'Content $action by admin',
          actionTaken: action,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Content ${action}d successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
      
      _loadData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to $action content: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _hidePost(Map<String, dynamic> post) async {
    try {
      await ForumManagementService.moderateContent(
        contentType: post['type'],
        contentId: post['id'],
        action: 'hide',
        reason: 'Hidden by admin during monitoring',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post hidden successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      
      _loadData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to hide post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deletePost(Map<String, dynamic> post) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to permanently delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ForumManagementService.moderateContent(
          contentType: post['type'],
          contentId: post['id'],
          action: 'delete',
          reason: 'Deleted by admin during monitoring',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        
        _loadData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getInitialFromName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'U';
    }
    return name.trim().substring(0, 1).toUpperCase();
  }
}