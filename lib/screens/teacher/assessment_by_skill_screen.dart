// lib/screens/teacher/assessment_by_skill_screen_refactored.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/student_model.dart';
import '../../models/academic_config_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';

class AssessmentBySkillScreenRefactored extends StatelessWidget {
  final List<StudentModel> students;
  final String grade;
  final AcademicConfigModel academicConfig;

  const AssessmentBySkillScreenRefactored({
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
      child: const _AssessmentBySkillContent(),
    );
  }
}

class _AssessmentBySkillContent extends StatelessWidget {
  const _AssessmentBySkillContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();

    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skill ${provider.currentQuestionIndex + 1}/${provider.questions.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${provider.students.length} students',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAcademicYearBanner(context),
          _buildQuestionHeader(context),
          _buildTimerControls(context),
          Expanded(child: _buildStudentsList(context)),
          _buildNavigationButtons(context),
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

  Widget _buildQuestionHeader(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final question = provider.currentQuestion;
        if (question == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF4e3f8a),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${provider.currentQuestionIndex + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                question.questionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerControls(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final question = provider.currentQuestion;
        if (question == null || question.inputType != 'seconds') {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.isTimerRunning
                          ? null
                          : () => _startGlobalTimer(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Stopwatch'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: provider.isTimerRunning
                        ? () => provider.stopTimer()
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
              if (provider.isTimerRunning)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    '${provider.timerSeconds} seconds',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4e3f8a),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentsList(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.students.length,
          itemBuilder: (context, index) {
            final student = provider.students[index];
            return _StudentScoreCard(student: student);
          },
        );
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (provider.currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      provider.previousQuestion();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
              if (provider.currentQuestionIndex > 0) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _handleNextOrSave(context),
                  icon: Icon(
                    provider.isLastQuestion ? Icons.check : Icons.arrow_forward,
                  ),
                  label: Text(
                    provider.isLastQuestion ? 'Save All' : 'Next Question',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startGlobalTimer(BuildContext context) {
    final provider = context.read<AssessmentProvider>();
    provider.startTimer();

    // Start periodic timer
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!provider.isTimerRunning) {
        timer.cancel();
        return;
      }
      provider.incrementTimer();
    });
  }

  Future<void> _handleNextOrSave(BuildContext context) async {
    final provider = context.read<AssessmentProvider>();

    // Validate all students have scores for current question
    bool allAnswered = true;
    for (var student in provider.students) {
      final response = provider.getResponse(
        student.id,
        provider.currentQuestionIndex,
      );
      if (response == null) {
        allAnswered = false;
        break;
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please score all students before proceeding'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (provider.isLastQuestion) {
      await _saveAllAssessments(context);
    } else {
      provider.nextQuestion();
    }
  }

  Future<void> _saveAllAssessments(BuildContext context) async {
    final provider = context.read<AssessmentProvider>();
    final authProvider = context.read<AuthProvider>();
    final connectivity = context.read<ConnectivityProvider>();

    final result = await provider.saveAllAssessments(
      teacherId: authProvider.currentUser!.uid,
      isOnline: connectivity.isOnline,
    );

    final saved = result['saved'] ?? 0;
    final failed = result['failed'] ?? 0;

    if (context.mounted) {
      await connectivity.updatePendingCount();

      if (failed == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully saved $saved assessments!\n'
              '${provider.academicConfig!.currentYear} - ${provider.academicConfig!.currentTerm}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved $saved assessments, $failed failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}

class _StudentScoreCard extends StatefulWidget {
  final StudentModel student;

  const _StudentScoreCard({required this.student});

  @override
  State<_StudentScoreCard> createState() => _StudentScoreCardState();
}

class _StudentScoreCardState extends State<_StudentScoreCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AssessmentProvider>();
    final initial = provider.getResponse(
      widget.student.id,
      provider.currentQuestionIndex,
    );
    _controller = TextEditingController(text: initial?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _useTimerValue() {
    final provider = context.read<AssessmentProvider>();
    _controller.text = provider.timerSeconds.toString();
    provider.setResponse(
      studentId: widget.student.id,
      questionIndex: provider.currentQuestionIndex,
      value: provider.timerSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final question = provider.currentQuestion;
        if (question == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.student.grade} - ${widget.student.division}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    keyboardType: question.inputType == 'integer'
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      suffixText: question.inputType == 'seconds' ? 's' : '',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final score = question.inputType == 'integer'
                          ? int.tryParse(value)
                          : double.tryParse(value);
                      provider.setResponse(
                        studentId: widget.student.id,
                        questionIndex: provider.currentQuestionIndex,
                        value: score,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    if (question.inputType == 'seconds')
                      IconButton(
                        icon: const Icon(Icons.timer, size: 20),
                        onPressed: _useTimerValue,
                        tooltip: 'Use timer value',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    IconButton(
                      icon:
                          const Icon(Icons.block, size: 20, color: Colors.red),
                      onPressed: () => _markAbsent(context),
                      tooltip: 'Mark absent',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markAbsent(BuildContext context) async {
    final provider = context.read<AssessmentProvider>();

    try {
      await provider.markStudentAbsent(widget.student.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.student.name} marked as absent')),
        );

        if (provider.students.isEmpty) {
          Navigator.pop(context);
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
}
