import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/forum_management_service.dart';

class ManageReportedContentPage extends StatefulWidget {
  const ManageReportedContentPage({super.key});

  @override
  State<ManageReportedContentPage> createState() => _ManageReportedContentPageState();
}

class _ManageReportedContentPageState extends State<ManageReportedContentPage> {
  String _selectedFilter = 'pending';
  bool _isLoading = true;
  List<Map<String, dynamic>> _reportedContent = [];
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
      // Load stats and reports concurrently
      final results = await Future.wait([
        ForumManagementService.getModerationStats(),
        ForumManagementService.getReportedContent(status: _selectedFilter),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _reportedContent = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reported content: $e');
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

  void _filterByStatus(String status) {
    setState(() {
      _selectedFilter = status;
    });
    _loadData();
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Header
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Reports',
                  _stats['totalReports']?.toString() ?? '0',
                  Icons.report_outlined,
                  AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending Review',
                  _stats['pendingReports']?.toString() ?? '0',
                  Icons.pending_outlined,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Actions Taken',
                  _stats['recentActions']?.toString() ?? '0',
                  Icons.check_circle_outline,
                  AppColors.successGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Filter Tabs
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
                Expanded(child: _buildFilterTab('Pending', 'pending')),
                Expanded(child: _buildFilterTab('Reviewed', 'reviewed')),
                Expanded(child: _buildFilterTab('Dismissed', 'dismissed')),
                Expanded(child: _buildFilterTab('All', '')),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Reported Content Management',
            style: const TextStyle(
              fontFamily: AppConstants.headingFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackText,
            ),
          ),
          
          const SizedBox(height: 16),

          // Content List
          if (_reportedContent.isEmpty)
            _buildEmptyState()
          else
            ..._reportedContent.map((report) => _buildReportCard(report)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppConstants.headingFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 10,
              color: AppColors.grayText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _filterByStatus(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.successGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppConstants.primaryFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.grayText,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
          Text(
            _selectedFilter == 'pending' 
                ? 'No pending reports'
                : _selectedFilter == 'reviewed'
                ? 'No reviewed reports'
                : _selectedFilter == 'dismissed'
                ? 'No dismissed reports'
                : 'No reported content',
            style: const TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 16,
              color: AppColors.grayText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reported content will appear here for moderation review.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.primaryFont,
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] ?? 'pending';
    final statusColor = status == 'pending' ? Colors.orange :
                       status == 'reviewed' ? AppColors.successGreen :
                       status == 'dismissed' ? AppColors.grayText : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (report['content_type'] ?? 'unknown').toString().toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppConstants.primaryFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryAccent,
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
          
          const SizedBox(height: 16),

          // Content Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grayText.withOpacity(0.2)),
            ),
            child: Text(
              report['content_text'] ?? 'No content available',
              style: const TextStyle(
                fontFamily: AppConstants.primaryFont,
                fontSize: 14,
                color: AppColors.blackText,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // Report Details
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
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
                Icons.flag_outlined,
                size: 16,
                color: AppColors.grayText,
              ),
              const SizedBox(width: 4),
              Text(
                'Reporter: ${report['reported_by_name'] ?? 'Anonymous'}',
                style: const TextStyle(
                  fontFamily: AppConstants.primaryFont,
                  fontSize: 12,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Report Reason
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
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

          // Admin Notes (if any)
          if (report['admin_notes']?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 16,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Admin Notes: ${report['admin_notes']}',
                      style: const TextStyle(
                        fontFamily: AppConstants.primaryFont,
                        fontSize: 12,
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons (only show for pending reports)
          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleReportAction(report, 'dismiss'),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Dismiss'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.grayText,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleReportAction(report, 'hide'),
                    icon: const Icon(Icons.visibility_off, size: 16),
                    label: const Text('Hide Content'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleReportAction(report, 'delete'),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _handleReportAction(Map<String, dynamic> report, String action) async {
    String? adminNotes;
    
    if (action != 'dismiss') {
      // Show confirmation dialog with notes input
      adminNotes = await _showActionDialog(action, report);
      if (adminNotes == null) return; // User cancelled
    }

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
        // First moderate the content
        await ForumManagementService.moderateContent(
          contentType: report['content_type'],
          contentId: report['content_id'],
          action: action,
          reason: adminNotes ?? 'Admin moderation action',
        );
        
        // Then update the report status
        await ForumManagementService.updateReportStatus(
          reportId: report['id'],
          newStatus: 'action_taken',
          adminNotes: adminNotes ?? 'Content ${action}d by admin',
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

  Future<String?> _showActionDialog(String action, Map<String, dynamic> report) async {
    final notesController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == 'hide' ? 'Hide' : 'Delete'} Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to ${action} this content?',
              style: const TextStyle(fontSize: 16),
            ),
            if (action == 'delete') ...[
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Admin notes (optional)',
                hintText: 'Reason for this action...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(notesController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'delete' ? Colors.red : Colors.orange,
            ),
            child: Text(
              action == 'hide' ? 'Hide Content' : 'Delete Content',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
