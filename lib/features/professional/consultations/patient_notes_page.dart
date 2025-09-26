import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/professional_service.dart';

// Add blackText color extension
extension AppColorsExtension on AppColors {
  static const Color blackText = Color(0xFF2D2D2D);
}

class PatientNotesPage extends StatefulWidget {
  const PatientNotesPage({super.key});

  @override
  State<PatientNotesPage> createState() => _PatientNotesPageState();
}

class _PatientNotesPageState extends State<PatientNotesPage> {
  final ProfessionalService _professionalService = ProfessionalService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _patientNotes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatientNotes();
  }

  Future<void> _loadPatientNotes() async {
    setState(() => _isLoading = true);
    
    try {
      _patientNotes = await _professionalService.getPatientNotes(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } catch (e) {
      print('Error loading patient notes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _loadPatientNotes();
  }

  String _getPatientInitial(String? patientName) {
    if (patientName == null || patientName.isEmpty) return 'P';
    return patientName[0].toUpperCase();
  }

  String _formatNoteDate(Map<String, dynamic> note) {
    if (note['created_at'] == null) return 'Recently';
    
    try {
      final timestamp = note['created_at'] as Timestamp;
      final date = timestamp.toDate();
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return 'Recently';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.successGreen,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Page Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Patient Notes',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColorsExtension.blackText,
                ),
              ),
            ),
            // Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.successGreen,
                onRefresh: _loadPatientNotes,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      
                      // Quick Stats
                      _buildQuickStats(),
                      const SizedBox(height: 24),
                      
                      // Patient Notes List
                      _buildPatientNotesList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_note_fab",
        onPressed: () {
          _showAddNoteDialog();
        },
        backgroundColor: AppColors.successGreen,
        child: Icon(
          Icons.add,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search patients or notes...',
          hintStyle: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.grayText,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.grayText,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(
          fontFamily: 'OpenSans',
          color: AppColors.blackText,
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.people,
              title: 'Total Patients',
              value: '${_patientNotes.length}',
              color: AppColors.primaryAccent,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.lightGray,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.note_alt,
              title: 'Total Notes',
              value: '${_patientNotes.fold(0, (sum, patient) => sum + (patient['consultationCount'] as int))}',
              color: AppColors.successGreen,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.lightGray,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.today,
              title: 'Recent Updates',
              value: '2',
              color: AppColors.purpleAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 12,
            color: AppColors.grayText,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientNotesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Records',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        const SizedBox(height: 16),
        if (_patientNotes.isEmpty)
          _buildEmptyNotes()
        else
          ..._patientNotes.map((note) => 
            _buildPatientNoteCard(note)
          ).toList(),
      ],
    );
  }

  Widget _buildPatientNoteCard(Map<String, dynamic> note) {
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
      ),
      child: Column(
        children: [
          // Patient Header
          Row(
            children: [
              // Patient Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _getPatientInitial(note['patient_name']),
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          note['patient_name'] ?? 'Unknown Patient',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackText,
                          ),
                        ),
                        Text(
                          'Notes available',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 12,
                            color: AppColors.grayText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created: ${_formatNoteDate(note)}',
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
          
          // Health Conditions
          if (note['health_conditions'] != null && (note['health_conditions'] as List).isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (note['health_conditions'] as List).map((condition) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      condition,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  )
                ).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Latest Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Note:',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note['note_text'] ?? 'No notes available',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 13,
                    color: AppColors.blackText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Tags
          if (note['tags'] != null && (note['tags'] as List).isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (note['tags'] as List).map((tag) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 10,
                        color: AppColors.successGreen,
                      ),
                    ),
                  )
                ).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _viewPatientHistory(note);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.grayText.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View History',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _addNote(note);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Note',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
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

  Widget _buildEmptyNotes() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 64,
            color: AppColors.grayText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Patient Notes Found',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding notes for your patients',
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

  void _viewPatientHistory(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${note['patientName']} - History',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackText,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Sample consultation history
                    _buildHistoryItem(
                      date: 'Sep 20, 2025',
                      note: 'Patient showing good progress with weight management. Recommended increasing protein intake.',
                      tags: ['Weight Management', 'Protein'],
                    ),
                    _buildHistoryItem(
                      date: 'Sep 10, 2025',
                      note: 'Initial assessment completed. Starting with calorie-controlled diet plan.',
                      tags: ['Initial Assessment', 'Diet Plan'],
                    ),
                    _buildHistoryItem(
                      date: 'Sep 1, 2025',
                      note: 'Patient consultation booking. Discussed health goals and expectations.',
                      tags: ['Booking', 'Goals'],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String note,
    required List<String> tags,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 13,
              color: AppColors.blackText,
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: tags.map((tag) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 9,
                      color: AppColors.successGreen,
                    ),
                  ),
                )
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _addNote(Map<String, dynamic> patient) {
    final TextEditingController noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Add Note for ${patient['patientName']}',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter consultation notes...',
            hintStyle: TextStyle(color: AppColors.grayText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.blackText,
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
              if (noteController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Note added for ${patient['patientName']}',
                      style: TextStyle(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
            ),
            child: Text(
              'Save Note',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Quick Add Note',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: Text(
          'Select a patient from the list to add consultation notes.',
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: AppColors.grayText,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
            ),
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}