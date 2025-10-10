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

  String _formatNoteDate(Map<String, dynamic> patient) {
    if (patient['latest_consultation'] == null) return 'No consultations';
    
    try {
      final consultation = patient['latest_consultation'] as Map<String, dynamic>;
      final timestamp = consultation['date'] as Timestamp;
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.note_alt,
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
                  'Patient Notes',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View and manage patient records',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.successGreen,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.successGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Green Header
            _buildHeader(),
            // White Content Container
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
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
            ),
          ],
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
              icon: Icons.event,
              title: 'Consultations',
              value: '${_patientNotes.fold(0, (sum, patient) => sum + (patient['consultation_count'] as int? ?? 0))}',
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
              title: 'This Week',
              value: '${_patientNotes.fold(0, (sum, patient) => sum + (patient['consultation_count'] as int? ?? 0))}',
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
          ),
      ],
    );
  }

  Widget _buildPatientNoteCard(Map<String, dynamic> patient) {
    final latestConsultation = patient['latest_consultation'] as Map<String, dynamic>?;
    final consultationCount = patient['consultation_count'] as int? ?? 0;
    
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
                    _getPatientInitial(patient['patient_name']),
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
                        Expanded(
                          child: Text(
                            patient['patient_name'] ?? 'Unknown Patient',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackText,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$consultationCount consultation${consultationCount != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last visit: ${_formatNoteDate(patient)}',
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
          if (patient['health_conditions'] != null && (patient['health_conditions'] as List).isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (patient['health_conditions'] as List).take(3).map((condition) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      condition is Map ? condition['condition_name'] ?? '' : condition.toString(),
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
          
          // Latest Consultation Topic
          if (latestConsultation != null) ...[
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
                    'Latest Consultation:',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    latestConsultation['topic'] ?? 'No topic specified',
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
          ],
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _viewPatientHistory(patient);
                  },
                  icon: Icon(
                    Icons.history,
                    size: 16,
                    color: AppColors.grayText,
                  ),
                  label: Text(
                    'History',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.grayText.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _viewPatientNotes(patient);
                  },
                  icon: Icon(
                    Icons.note,
                    size: 16,
                    color: AppColors.primaryAccent,
                  ),
                  label: Text(
                    'Notes',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primaryAccent.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _addNote(patient);
                  },
                  icon: Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.white,
                  ),
                  label: Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
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

  void _viewPatientNotes(Map<String, dynamic> patient) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.successGreen),
      ),
    );

    // Fetch all notes for this patient
    final notes = await _professionalService.getPatientAllNotes(
      patient['patient_id'],
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    // Show notes modal
    if (mounted) {
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
                Row(
                  children: [
                    Icon(
                      Icons.note_alt,
                      color: AppColors.primaryAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${patient['patient_name']}',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackText,
                            ),
                          ),
                          Text(
                            'All Notes',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 14,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.grayText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${notes.length} note${notes.length != 1 ? 's' : ''} recorded',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_alt_outlined,
                                size: 48,
                                color: AppColors.grayText.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notes found',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grayText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start adding notes for this patient',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  color: AppColors.grayText,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return _buildNoteItem(note);
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _addNote(patient);
                        },
                        icon: Icon(Icons.add, color: AppColors.white, size: 18),
                        label: Text(
                          'Add Note',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.grayText.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            color: AppColors.grayText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildNoteItem(Map<String, dynamic> note) {
    String formatDate(Timestamp? timestamp) {
      if (timestamp == null) return 'Date not available';
      try {
        final date = timestamp.toDate();
        return '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.day}, ${date.year}';
      } catch (e) {
        return 'Date error';
      }
    }

    final tags = note['tags'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryAccent.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.edit_note,
                  size: 16,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formatDate(note['created_at']),
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              note['note_text'] ?? 'No note text',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 13,
                color: AppColors.blackText,
                height: 1.4,
              ),
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.label,
                        size: 10,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tag.toString(),
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                )
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _viewPatientHistory(Map<String, dynamic> patient) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.successGreen),
      ),
    );

    // Fetch consultation history
    final consultations = await _professionalService.getPatientConsultationHistory(
      patient['patient_id'],
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    // Show history modal
    if (mounted) {
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${patient['patient_name']} - History',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackText,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.grayText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${consultations.length} consultation${consultations.length != 1 ? 's' : ''} recorded',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: AppColors.grayText,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: consultations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 48,
                                color: AppColors.grayText.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No consultation history',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  color: AppColors.grayText,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: consultations.length,
                          itemBuilder: (context, index) {
                            final consultation = consultations[index];
                            return _buildHistoryItem(consultation);
                          },
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
  }

  Widget _buildHistoryItem(Map<String, dynamic> consultation) {
    String formatDate(Timestamp? timestamp) {
      if (timestamp == null) return 'Date not available';
      try {
        final date = timestamp.toDate();
        return '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.day}, ${date.year}';
      } catch (e) {
        return 'Date error';
      }
    }

    final notes = consultation['notes'] as List<dynamic>? ?? [];
    final hasNotes = notes.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.successGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.event,
                  size: 14,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(consultation['consultation_date']),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackText,
                      ),
                    ),
                    Text(
                      consultation['consultation_time'] ?? 'Time not specified',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 11,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(consultation['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  consultation['status'] ?? 'Unknown',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(consultation['status']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            consultation['topic'] ?? 'No topic specified',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              color: AppColors.blackText,
            ),
          ),
          if (consultation['reference_no'] != null && consultation['reference_no'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ref: ${consultation['reference_no']}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 10,
                color: AppColors.grayText,
              ),
            ),
          ],
          if (hasNotes) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt,
                        size: 12,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Notes:',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...notes.map((note) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• ${note['note_text'] ?? ''}',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 11,
                        color: AppColors.blackText,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return AppColors.successGreen;
      case 'scheduled':
      case 'confirmed':
        return AppColors.primaryAccent;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.grayText;
    }
  }

  void _addNote(Map<String, dynamic> patient) {
    final TextEditingController noteController = TextEditingController();
    final TextEditingController tagsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.note_add, color: AppColors.successGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Add Note for ${patient['patient_name']}',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.blackText,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Note',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter consultation notes, observations, recommendations...',
                      hintStyle: TextStyle(
                        fontFamily: 'OpenSans',
                        color: AppColors.grayText,
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.grayText.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.successGreen, width: 2),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tags (optional)',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Weight Management, Diabetes, Follow-up',
                      hintStyle: TextStyle(
                        fontFamily: 'OpenSans',
                        color: AppColors.grayText,
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.grayText.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.successGreen, width: 2),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: AppColors.blackText,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    color: isSaving ? AppColors.grayText : AppColors.blackText,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (noteController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a note'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() => isSaving = true);

                  try {
                    // Parse tags
                    List<String> tags = tagsController.text
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toList();

                    // Get health conditions from patient data
                    List<String> healthConditions = [];
                    if (patient['health_conditions'] != null) {
                      final conditions = patient['health_conditions'] as List;
                      healthConditions = conditions.map((c) {
                        if (c is Map && c.containsKey('condition_name')) {
                          return c['condition_name'].toString();
                        }
                        return c.toString();
                      }).toList();
                    }

                    await _professionalService.addPatientNote(
                      patientId: patient['patient_id'],
                      patientName: patient['patient_name'],
                      noteText: noteController.text,
                      tags: tags,
                      healthConditions: healthConditions,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Note added successfully for ${patient['patient_name']}',
                            style: TextStyle(color: AppColors.white),
                          ),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                      // Reload patient notes
                      _loadPatientNotes();
                    }
                  } catch (e) {
                    setState(() => isSaving = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add note: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaving ? AppColors.grayText : AppColors.successGreen,
                ),
                child: isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
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
      },
    );
  }
}
