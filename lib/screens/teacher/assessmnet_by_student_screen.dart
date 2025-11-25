// lib/screens/teacher/assessment_by_student_screen_refactored.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/student_model.dart';
import '../../models/academic_config_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';

class AssessmentByStudentScreenRefactored extends StatelessWidget {
  final List<StudentModel> students;
  final String grade;
  final AcademicConfigModel academicConfig;

  const AssessmentByStudentScreenRefactored({
    Key? key,
    required this.students,
    required this.grade,
    required this.academicConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = AssessmentProvider();
        provider.initializeAssessment(
          students: students,
          level: students.first.level,
          academicConfig: academicConfig,
        );
        return provider;
      },
      child: const _AssessmentContent(),
    );
  }
}

class _AssessmentContent extends StatelessWidget {
  const _AssessmentContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();

    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${provider.errorMessage}'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assess Student ${provider.currentStudentIndex + 1}/${provider.students.length}',
        ),
      ),
      body: Column(
        children: [
          _buildAcademicYearBanner(context),
          _buildStudentCard(context),
          _buildActionButtons(context),
          Expanded(child: _buildQuestionsList(context)),
          _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildAcademicYearBanner(BuildContext context) {
    final config = context.select<AssessmentProvider, AcademicConfigModel?>(
      (p) => p.academicConfig,
    );

    if (config == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            '${config.currentYear} • ${config.currentTerm}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final student = provider.currentStudent;
        if (student == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF4e3f8a),
                  child: Text(
                    student.name[0],
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('UID: ${student.uid}'),
                      Text('${student.grade} - ${student.division}'),
                      Text('Level ${student.level}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _markAbsent(context),
              icon: const Icon(Icons.block, size: 18),
              label: const Text('Mark Absent'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _markLeftSchool(context),
              icon: const Icon(Icons.person_remove, size: 18),
              label: const Text('Left School'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.questions.length,
          itemBuilder: (context, index) {
            final question = provider.questions[index];
            return _QuestionCard(
              question: question,
              questionNumber: index,
            );
          },
        );
      },
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: Consumer<AssessmentProvider>(
          builder: (context, provider, child) {
            return ElevatedButton(
              onPressed: () => _saveAssessment(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save & Next Student',
                style: TextStyle(fontSize: 18),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _markAbsent(BuildContext context) async {
    final provider = context.read<AssessmentProvider>();
    final student = provider.currentStudent;
    if (student == null) return;

    try {
      await provider.markStudentAbsent(student.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.name} marked as absent')),
        );

        if (provider.students.isEmpty) {
          Navigator.pop(context);
        } else {
          // Auto-advance to next student
          provider.nextStudent();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markLeftSchool(BuildContext context) async {
    final provider = context.read<AssessmentProvider>();
    final student = provider.currentStudent;
    if (student == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Removal'),
        content: Text(
          'Are you sure ${student.name} has left the school?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Handle left school logic
      provider.nextStudent();
    }
  }

  Future<void> _saveAssessment(BuildContext context) async {
    final provider = context.read<AssessmentProvider>();
    final authProvider = context.read<AuthProvider>();
    final connectivity = context.read<ConnectivityProvider>();

    if (!provider.validateCurrentStudentResponses()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all assessments'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await provider.saveCurrentAssessment(
      teacherId: authProvider.currentUser!.uid,
      isOnline: connectivity.isOnline,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              connectivity.isOnline
                  ? 'Assessment saved and synced!'
                  : 'Assessment saved locally. Will sync when online.',
            ),
            backgroundColor:
                connectivity.isOnline ? Colors.green : Colors.orange,
          ),
        );

        if (provider.isLastStudent) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All students assessed!')),
          );
        } else {
          provider.nextStudent();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    await connectivity.updatePendingCount();
  }
}

// Question Card with Timer
class _QuestionCard extends StatefulWidget {
  final dynamic question;
  final int questionNumber;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AssessmentProvider>();
    final initial = provider.getCurrentResponse(widget.questionNumber);
    _controller = TextEditingController(text: initial?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final provider = context.read<AssessmentProvider>();
    provider.startTimer();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      provider.incrementTimer();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    final provider = context.read<AssessmentProvider>();
    provider.stopTimer();

    _controller.text = provider.timerSeconds.toString();
    provider.setCurrentResponse(widget.questionNumber, provider.timerSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${widget.questionNumber + 1}: ${question.questionText}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Timer controls for seconds type
            if (question.inputType == 'seconds') ...[
              Consumer<AssessmentProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  provider.isTimerRunning ? null : _startTimer,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed:
                                provider.isTimerRunning ? _stopTimer : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (provider.isTimerRunning) ...[
                        const SizedBox(height: 16),
                        Text(
                          '${provider.timerSeconds}s',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4e3f8a),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // Score input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: question.inputType == 'integer'
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Score',
                      suffixText: question.inputType == 'seconds' ? 'sec' : '',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final score = question.inputType == 'integer'
                          ? int.tryParse(value)
                          : double.tryParse(value);
                      context.read<AssessmentProvider>().setCurrentResponse(
                            widget.questionNumber,
                            score,
                          );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        final current = int.tryParse(_controller.text) ?? 0;
                        _controller.text = (current + 1).toString();
                        context.read<AssessmentProvider>().setCurrentResponse(
                              widget.questionNumber,
                              current + 1,
                            );
                      },
                      icon: const Icon(Icons.arrow_drop_up),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200]),
                    ),
                    IconButton(
                      onPressed: () {
                        final current = int.tryParse(_controller.text) ?? 0;
                        if (current > 0) {
                          _controller.text = (current - 1).toString();
                          context.read<AssessmentProvider>().setCurrentResponse(
                                widget.questionNumber,
                                current - 1,
                              );
                        }
                      },
                      icon: const Icon(Icons.arrow_drop_down),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
