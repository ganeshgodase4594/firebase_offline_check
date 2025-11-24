// lib/screens/coordinator/academic_year_management_screen.dart
import 'package:brainmoto_app/service/firebase_service_extension.dart';
import 'package:flutter/material.dart';
import '../../models/school_model.dart';
import '../../models/academic_config_model.dart';

class AcademicYearManagementScreen extends StatefulWidget {
  final SchoolModel school;

  const AcademicYearManagementScreen({super.key, required this.school});

  @override
  State<AcademicYearManagementScreen> createState() =>
      _AcademicYearManagementScreenState();
}

class _AcademicYearManagementScreenState
    extends State<AcademicYearManagementScreen> {
  AcademicConfigModel? _currentConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    setState(() => _isLoading = true);

    final config =
        await FirebaseServiceExtensions.getAcademicConfig(widget.school.id);

    setState(() {
      _currentConfig = config;
      _isLoading = false;
    });
  }

  Future<void> _createNewAcademicYear() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _NewAcademicYearDialog(),
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final config = AcademicConfigModel(
        id: '',
        schoolId: widget.school.id,
        currentYear: result['year'],
        currentTerm: 'Term 1',
        yearStartDate: result['startDate'],
        yearEndDate: result['endDate'],
        term1EndDate: result['term1EndDate'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseServiceExtensions.createAcademicConfig(config);
      await _loadCurrentConfig();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Academic year created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _switchToTerm2() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch to Term 2'),
        content: const Text(
          'Are you sure you want to switch to Term 2?\n\n'
          'This will affect all new assessments submitted by teachers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Switch to Term 2'),
          ),
        ],
      ),
    );

    if (confirm != true || _currentConfig == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseServiceExtensions.updateAcademicConfig(
        _currentConfig!.id,
        {'currentTerm': 'Term 2'},
      );
      await _loadCurrentConfig();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Switched to Term 2 successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _archiveCurrentYear() async {
    if (_currentConfig == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Academic Year'),
        content: const Text(
          'This will:\n'
          '• Move all assessment data to archive\n'
          '• Clear active assessments for this year\n'
          '• Prepare system for new academic year\n\n'
          'This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Archive Year'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseServiceExtensions.archiveAcademicYearData(
        widget.school.id,
        _currentConfig!.currentYear,
      );

      // Deactivate current config
      await FirebaseServiceExtensions.updateAcademicConfig(
        _currentConfig!.id,
        {'isActive': false},
      );

      await _loadCurrentConfig();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Academic year archived successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Year Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentConfig == null
              ? _buildNoConfigView()
              : _buildConfigView(),
    );
  }

  Widget _buildNoConfigView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Active Academic Year',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new academic year to begin',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewAcademicYear,
            icon: const Icon(Icons.add),
            label: const Text('Create Academic Year'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigView() {
    final config = _currentConfig!;
    final isTerm1 = config.currentTerm == 'Term 1';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current Status Card
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Active Academic Year',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(),
                _buildInfoRow('Year', config.currentYear),
                _buildInfoRow('Current Term', config.currentTerm),
                _buildInfoRow('Start Date', _formatDate(config.yearStartDate)),
                _buildInfoRow('End Date', _formatDate(config.yearEndDate)),
                if (config.term1EndDate != null)
                  _buildInfoRow(
                      'Term 1 Ends', _formatDate(config.term1EndDate!)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Term Management
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Term Management',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (isTerm1) ...[
                  const Text(
                    'Currently in Term 1. Switch to Term 2 when Term 1 assessments are complete.',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _switchToTerm2,
                    icon: const Icon(Icons.navigate_next),
                    label: const Text('Switch to Term 2'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              'Currently in Term 2 - Final term of academic year'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Archive Management
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Year End Management',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Archive current year data and prepare for new academic year.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _archiveCurrentYear,
                  icon: const Icon(Icons.archive),
                  label: const Text('Archive Current Year'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Info Card
        Card(
          color: Colors.blue[50],
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'How it works',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                    '• Teachers automatically use the active year/term when submitting assessments'),
                Text(
                    '• Each student can be assessed twice per year (once per term)'),
                Text('• Archive old data before starting a new academic year'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label + ':',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ============================================
// NEW ACADEMIC YEAR DIALOG
// ============================================

class _NewAcademicYearDialog extends StatefulWidget {
  @override
  State<_NewAcademicYearDialog> createState() => _NewAcademicYearDialogState();
}

class _NewAcademicYearDialogState extends State<_NewAcademicYearDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _term1EndDate;
  String? _year;

  Future<void> _selectDate(BuildContext context, String field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        switch (field) {
          case 'start':
            _startDate = picked;
            // Auto-generate year string
            final endYear = picked.add(const Duration(days: 365)).year;
            _year = '${picked.year}-$endYear';
            break;
          case 'end':
            _endDate = picked;
            break;
          case 'term1End':
            _term1EndDate = picked;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Academic Year'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: const Text('Year Start Date'),
                subtitle: Text(_startDate != null
                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                    : 'Not selected'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'start'),
              ),
              ListTile(
                title: const Text('Year End Date'),
                subtitle: Text(_endDate != null
                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                    : 'Not selected'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'end'),
              ),
              ListTile(
                title: const Text('Term 1 End Date (optional)'),
                subtitle: Text(_term1EndDate != null
                    ? '${_term1EndDate!.day}/${_term1EndDate!.month}/${_term1EndDate!.year}'
                    : 'Not selected'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'term1End'),
              ),
              if (_year != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Academic Year: $_year',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startDate == null || _endDate == null || _year == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please select start and end dates')),
              );
              return;
            }

            Navigator.pop(context, {
              'year': _year,
              'startDate': _startDate,
              'endDate': _endDate,
              'term1EndDate': _term1EndDate,
            });
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
