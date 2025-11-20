// lib/screens/teacher/assessment_by_student_screen.dart
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:brainmoto_app/service/offline_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../models/student_model.dart';
import '../../models/assessment_model.dart';
import '../../models/assessment_question_model.dart';

import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';

class AssessmentByStudentScreen extends StatefulWidget {
  final List<StudentModel> students;
  final String grade;

  const AssessmentByStudentScreen({
    Key? key,
    required this.students,
    required this.grade,
  }) : super(key: key);

  @override
  State<AssessmentByStudentScreen> createState() =>
      _AssessmentByStudentScreenState();
}

class _AssessmentByStudentScreenState extends State<AssessmentByStudentScreen> {
  int _currentStudentIndex = 0;
  List<AssessmentQuestionModel> _questions = [];
  Map<String, dynamic> _responses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    final student = widget.students[_currentStudentIndex];
    _questions = await FirebaseService.getQuestionsByLevel(student.level);

    setState(() => _isLoading = false);
  }

  Future<void> _markAbsent() async {
    final student = widget.students[_currentStudentIndex];
    await FirebaseService.markStudentAbsent(student.id, true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${student.name} marked as absent')),
      );
      _nextStudent();
    }
  }

  Future<void> _markLeftSchool() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Removal'),
        content: const Text(
            'Are you sure this student has left the school? This action cannot be undone.'),
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
      final student = widget.students[_currentStudentIndex];
      await FirebaseService.markStudentLeftSchool(student.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.name} removed from school')),
        );
        _nextStudent();
      }
    }
  }

  void _nextStudent() {
    if (_currentStudentIndex < widget.students.length - 1) {
      setState(() {
        _currentStudentIndex++;
        _responses.clear();
      });
      _loadQuestions();
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All students assessed!')),
      );
    }
  }

  Future<void> _saveAssessment() async {
    // Validate all responses
    if (_responses.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all assessments'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final connectivity =
        Provider.of<ConnectivityProvider>(context, listen: false);
    final student = widget.students[_currentStudentIndex];

    final assessment = AssessmentModel(
      id: '',
      studentId: student.id,
      teacherId: authProvider.currentUser!.uid,
      schoolId: student.schoolId,
      level: student.level,
      responses: _responses,
      assessmentDate: DateTime.now(),
      isSynced: connectivity.isOnline,
      assessmentType: 'by_student',
    );

    try {
      if (connectivity.isOnline) {
        await FirebaseService.createAssessment(assessment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assessment saved and synced!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await OfflineService.saveAssessmentOffline(assessment);
        await connectivity.updatePendingCount();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assessment saved locally. Will sync when online.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      _nextStudent();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final student = widget.students[_currentStudentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Assess Student ${_currentStudentIndex + 1}/${widget.students.length}'),
      ),
      body: Column(
        children: [
          // Student Info Card
          Card(
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
                        Text('${student.grade} - ${student.division}'),
                        Text('Level ${student.level}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _markAbsent,
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('Mark Absent'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _markLeftSchool,
                    icon: const Icon(Icons.person_remove, size: 18),
                    label: const Text('Left School'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return QuestionCard(
                  question: _questions[index],
                  questionNumber: index,
                  onScoreChanged: (score) {
                    setState(() {
                      _responses['response$index'] = score;
                    });
                  },
                  initialValue: _responses['response$index'],
                );
              },
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAssessment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save & Next Student',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final AssessmentQuestionModel question;
  final int questionNumber;
  final Function(dynamic) onScoreChanged;
  final dynamic initialValue;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.onScoreChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late TextEditingController _controller;
  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _seconds = 0;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _controller.text = _seconds.toString();
      widget.onScoreChanged(_seconds);
    });
  }

  void _startCountdown(int duration) async {
    setState(() {
      _seconds = duration;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _stopTimer();
        // Vibrate and alert
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time\'s up!'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // Future<void> _showVideoHelp() async {
  //   if (widget.question.videoUrl != null) {
  //     final Uri url = Uri.parse(widget.question.videoUrl!);
  //     if (await canLaunchUrl(url)) {
  //       await launchUrl(url, mode: LaunchMode.externalApplication);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Q${widget.questionNumber + 1}: ${widget.question.questionText}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.question.videoUrl != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline,
                        color: Color(0xFF4e3f8a)),
                    onPressed: null,
                    tooltip: 'Watch demo video',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Timer Controls (for seconds type)
            if (widget.question.inputType == 'seconds') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTimerRunning ? null : _startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Stopwatch'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isTimerRunning ? _stopTimer : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Preset countdown buttons
              if (widget.question.presetTimer != null)
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _startCountdown(30),
                      child: const Text('30s'),
                    ),
                    TextButton(
                      onPressed: () => _startCountdown(60),
                      child: const Text('60s'),
                    ),
                    TextButton(
                      onPressed: () => _startCountdown(90),
                      child: const Text('90s'),
                    ),
                  ],
                ),

              if (_isTimerRunning)
                Center(
                  child: Text(
                    _seconds.toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4e3f8a),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            // Score Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: widget.question.inputType == 'integer'
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Score',
                      suffixText:
                          widget.question.inputType == 'seconds' ? 'sec' : '',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final score = widget.question.inputType == 'integer'
                          ? int.tryParse(value)
                          : double.tryParse(value);
                      widget.onScoreChanged(score);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Stepper buttons
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        final current = int.tryParse(_controller.text) ?? 0;
                        _controller.text = (current + 1).toString();
                        widget.onScoreChanged(current + 1);
                      },
                      icon: const Icon(Icons.arrow_drop_up),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final current = int.tryParse(_controller.text) ?? 0;
                        if (current > 0) {
                          _controller.text = (current - 1).toString();
                          widget.onScoreChanged(current - 1);
                        }
                      },
                      icon: const Icon(Icons.arrow_drop_down),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
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
