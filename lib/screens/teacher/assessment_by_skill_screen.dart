// // lib/screens/teacher/assessment_by_skill_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';

// import '../../models/student_model.dart';
// import '../../models/assessment_model.dart';
// import '../../models/assessment_question_model.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/connectivity_provider.dart';
// import '../../service/firebase_service.dart';
// import '../../service/offline_service.dart';

// class AssessmentBySkillScreen extends StatefulWidget {
//   final List<StudentModel> students;
//   final String grade;

//   const AssessmentBySkillScreen({
//     Key? key,
//     required this.students,
//     required this.grade,
//   }) : super(key: key);

//   @override
//   State<AssessmentBySkillScreen> createState() =>
//       _AssessmentBySkillScreenState();
// }

// class _AssessmentBySkillScreenState extends State<AssessmentBySkillScreen> {
//   List<AssessmentQuestionModel> _questions = [];
//   int _currentQuestionIndex = 0;
//   Map<String, dynamic> _allResponses = {}; // studentId -> score
//   bool _isLoading = true;
//   Timer? _timer;
//   int _seconds = 0;
//   bool _isTimerRunning = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadQuestions();
//     _initializeResponses();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadQuestions() async {
//     setState(() => _isLoading = true);

//     // Get level from first student (assuming all students in same grade have same level)
//     final level = widget.students.first.level;
//     _questions = await FirebaseService.getQuestionsByLevel(level);

//     setState(() => _isLoading = false);
//   }

//   void _initializeResponses() {
//     for (var student in widget.students) {
//       _allResponses[student.id] = {};
//     }
//   }

//   Future<void> _markStudentAbsent(StudentModel student) async {
//     await FirebaseService.markStudentAbsent(student.id, true);

//     setState(() {
//       widget.students.removeWhere((s) => s.id == student.id);
//       _allResponses.remove(student.id);
//     });

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('${student.name} marked as absent')),
//       );
//     }

//     if (widget.students.isEmpty) {
//       Navigator.pop(context);
//     }
//   }

//   void _nextQuestion() {
//     if (_currentQuestionIndex < _questions.length - 1) {
//       setState(() {
//         _currentQuestionIndex++;
//         _seconds = 0;
//         _isTimerRunning = false;
//         _timer?.cancel();
//       });
//     } else {
//       _saveAllAssessments();
//     }
//   }

//   void _previousQuestion() {
//     if (_currentQuestionIndex > 0) {
//       setState(() {
//         _currentQuestionIndex--;
//         _seconds = 0;
//         _isTimerRunning = false;
//         _timer?.cancel();
//       });
//     }
//   }

//   Future<void> _saveAllAssessments() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final connectivity =
//         Provider.of<ConnectivityProvider>(context, listen: false);

//     int savedCount = 0;
//     int errorCount = 0;

//     for (var student in widget.students) {
//       if (student.isAbsent) continue;

//       final responses = _allResponses[student.id] as Map<String, dynamic>;

//       // Check if all questions are answered
//       if (responses.length != _questions.length) {
//         errorCount++;
//         continue;
//       }

//       final assessment = AssessmentModel(
//         id: '',
//         studentId: student.id,
//         teacherId: authProvider.currentUser!.uid,
//         schoolId: student.schoolId,
//         level: student.level,
//         responses: responses,
//         assessmentDate: DateTime.now(),
//         isSynced: connectivity.isOnline,
//         assessmentType: 'by_skill',
//       );

//       try {
//         if (connectivity.isOnline) {
//           await FirebaseService.createAssessment(assessment);
//         } else {
//           await OfflineService.saveAssessmentOffline(assessment);
//         }
//         savedCount++;
//       } catch (e) {
//         errorCount++;
//       }
//     }

//     if (mounted) {
//       await connectivity.updatePendingCount();

//       if (errorCount == 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Successfully saved $savedCount assessments!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Saved $savedCount assessments, $errorCount failed'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }

//       Navigator.pop(context);
//     }
//   }

//   void _startTimer() {
//     setState(() {
//       _seconds = 0;
//       _isTimerRunning = true;
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _seconds++;
//       });
//     });
//   }

//   void _stopTimer() {
//     _timer?.cancel();
//     setState(() {
//       _isTimerRunning = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Loading...')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     final currentQuestion = _questions[_currentQuestionIndex];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Skill ${_currentQuestionIndex + 1}/${_questions.length}',
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Center(
//               child: Text(
//                 '${widget.students.length} students',
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Question Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             color: const Color(0xFF4e3f8a),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Question ${_currentQuestionIndex + 1}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   currentQuestion.questionText,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Timer Controls (for seconds type)
//           if (currentQuestion.inputType == 'seconds')
//             Container(
//               padding: const EdgeInsets.all(16),
//               color: Colors.grey[100],
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: _isTimerRunning ? null : _startTimer,
//                           icon: const Icon(Icons.play_arrow),
//                           label: const Text('Start Stopwatch'),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton.icon(
//                         onPressed: _isTimerRunning ? _stopTimer : null,
//                         icon: const Icon(Icons.stop),
//                         label: const Text('Stop'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (_isTimerRunning)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 16),
//                       child: Text(
//                         '$_seconds seconds',
//                         style: const TextStyle(
//                           fontSize: 36,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF4e3f8a),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//           // Students List
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: widget.students.length,
//               itemBuilder: (context, index) {
//                 final student = widget.students[index];
//                 return StudentScoreCard(
//                   student: student,
//                   question: currentQuestion,
//                   questionIndex: _currentQuestionIndex,
//                   currentTimerValue: _seconds,
//                   onScoreChanged: (score) {
//                     setState(() {
//                       (_allResponses[student.id] as Map<String, dynamic>)[
//                           'response$_currentQuestionIndex'] = score;
//                     });
//                   },
//                   onMarkAbsent: () => _markStudentAbsent(student),
//                   initialValue: (_allResponses[student.id] as Map<String,
//                       dynamic>)['response$_currentQuestionIndex'],
//                 );
//               },
//             ),
//           ),

//           // Navigation Buttons
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: const Offset(0, -3),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 if (_currentQuestionIndex > 0)
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: _previousQuestion,
//                       icon: const Icon(Icons.arrow_back),
//                       label: const Text('Previous'),
//                     ),
//                   ),
//                 if (_currentQuestionIndex > 0) const SizedBox(width: 16),
//                 Expanded(
//                   flex: 2,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       // Check if all students have scores for current question
//                       bool allAnswered = true;
//                       for (var student in widget.students) {
//                         final responses =
//                             _allResponses[student.id] as Map<String, dynamic>;
//                         if (!responses
//                             .containsKey('response$_currentQuestionIndex')) {
//                           allAnswered = false;
//                           break;
//                         }
//                       }

//                       if (!allAnswered) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                                 'Please score all students before proceeding'),
//                             backgroundColor: Colors.orange,
//                           ),
//                         );
//                         return;
//                       }

//                       _nextQuestion();
//                     },
//                     icon: Icon(
//                       _currentQuestionIndex == _questions.length - 1
//                           ? Icons.check
//                           : Icons.arrow_forward,
//                     ),
//                     label: Text(
//                       _currentQuestionIndex == _questions.length - 1
//                           ? 'Save All'
//                           : 'Next Question',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class StudentScoreCard extends StatefulWidget {
//   final StudentModel student;
//   final AssessmentQuestionModel question;
//   final int questionIndex;
//   final int currentTimerValue;
//   final Function(dynamic) onScoreChanged;
//   final VoidCallback onMarkAbsent;
//   final dynamic initialValue;

//   const StudentScoreCard({
//     Key? key,
//     required this.student,
//     required this.question,
//     required this.questionIndex,
//     required this.currentTimerValue,
//     required this.onScoreChanged,
//     required this.onMarkAbsent,
//     this.initialValue,
//   }) : super(key: key);

//   @override
//   State<StudentScoreCard> createState() => _StudentScoreCardState();
// }

// class _StudentScoreCardState extends State<StudentScoreCard> {
//   late TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(
//       text: widget.initialValue?.toString() ?? '',
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _useTimerValue() {
//     _controller.text = widget.currentTimerValue.toString();
//     widget.onScoreChanged(widget.currentTimerValue);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             // Student Info
//             Expanded(
//               flex: 2,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.student.name,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   Text(
//                     '${widget.student.grade} - ${widget.student.division}',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Score Input
//             SizedBox(
//               width: 100,
//               child: TextField(
//                 controller: _controller,
//                 keyboardType: widget.question.inputType == 'integer'
//                     ? TextInputType.number
//                     : const TextInputType.numberWithOptions(decimal: true),
//                 textAlign: TextAlign.center,
//                 decoration: InputDecoration(
//                   isDense: true,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 8,
//                   ),
//                   suffixText: widget.question.inputType == 'seconds' ? 's' : '',
//                   border: const OutlineInputBorder(),
//                 ),
//                 onChanged: (value) {
//                   final score = widget.question.inputType == 'integer'
//                       ? int.tryParse(value)
//                       : double.tryParse(value);
//                   widget.onScoreChanged(score);
//                 },
//               ),
//             ),

//             // Quick Actions
//             const SizedBox(width: 8),
//             Column(
//               children: [
//                 if (widget.question.inputType == 'seconds')
//                   IconButton(
//                     icon: const Icon(Icons.timer, size: 20),
//                     onPressed: _useTimerValue,
//                     tooltip: 'Use timer value',
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 IconButton(
//                   icon: const Icon(Icons.block, size: 20, color: Colors.red),
//                   onPressed: widget.onMarkAbsent,
//                   tooltip: 'Mark absent',
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/teacher/assessment_by_skill_screen_v2.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../models/student_model.dart';
import '../../models/assessment_model.dart';
import '../../models/assessment_question_model.dart';
import '../../models/academic_config_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../service/firebase_service.dart';
import '../../service/offline_service.dart';

class AssessmentBySkillScreen extends StatefulWidget {
  final List<StudentModel> students;
  final String grade;
  final AcademicConfigModel academicConfig;

  const AssessmentBySkillScreen({
    Key? key,
    required this.students,
    required this.grade,
    required this.academicConfig,
  }) : super(key: key);

  @override
  State<AssessmentBySkillScreen> createState() =>
      _AssessmentBySkillScreenV2State();
}

class _AssessmentBySkillScreenV2State extends State<AssessmentBySkillScreen> {
  List<AssessmentQuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _allResponses = {}; // studentId -> score
  bool _isLoading = true;
  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _initializeResponses();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    // Get level from first student (assuming all students in same grade have same level)
    final level = widget.students.first.level;
    _questions = await FirebaseService.getQuestionsByLevel(level);

    setState(() => _isLoading = false);
  }

  void _initializeResponses() {
    for (var student in widget.students) {
      _allResponses[student.id] = {};
    }
  }

  Future<void> _markStudentAbsent(StudentModel student) async {
    await FirebaseService.markStudentAbsent(student.id, true);

    setState(() {
      widget.students.removeWhere((s) => s.id == student.id);
      _allResponses.remove(student.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${student.name} marked as absent')),
      );
    }

    if (widget.students.isEmpty) {
      Navigator.pop(context);
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _seconds = 0;
        _isTimerRunning = false;
        _timer?.cancel();
      });
    } else {
      _saveAllAssessments();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _seconds = 0;
        _isTimerRunning = false;
        _timer?.cancel();
      });
    }
  }

  Future<void> _saveAllAssessments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final connectivity =
        Provider.of<ConnectivityProvider>(context, listen: false);

    int savedCount = 0;
    int errorCount = 0;

    for (var student in widget.students) {
      if (student.isAbsent) continue;

      final responses = _allResponses[student.id] as Map<String, dynamic>;

      // Check if all questions are answered
      if (responses.length != _questions.length) {
        errorCount++;
        continue;
      }

      // Create assessment with academic year and term
      final assessment = AssessmentModel(
        id: '',
        studentId: student.id,
        teacherId: authProvider.currentUser!.uid,
        schoolId: student.schoolId,
        level: student.level,
        responses: responses,
        assessmentDate: DateTime.now(),
        academicYear: widget.academicConfig.currentYear, // Auto-tagged
        term: widget.academicConfig.currentTerm, // Auto-tagged
        isSynced: connectivity.isOnline,
        assessmentType: 'by_skill',
      );

      try {
        if (connectivity.isOnline) {
          await FirebaseService.createAssessment(assessment);
        } else {
          await OfflineService.saveAssessmentOffline(assessment);
        }
        savedCount++;
      } catch (e) {
        errorCount++;
      }
    }

    if (mounted) {
      await connectivity.updatePendingCount();

      if (errorCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully saved $savedCount assessments!\n'
              '${widget.academicConfig.currentYear} - ${widget.academicConfig.currentTerm}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved $savedCount assessments, $errorCount failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      Navigator.pop(context);
    }
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skill ${_currentQuestionIndex + 1}/${_questions.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${widget.students.length} students',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Academic Year Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '${widget.academicConfig.currentYear} • ${widget.academicConfig.currentTerm}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Question Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF4e3f8a),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentQuestion.questionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Timer Controls (for seconds type)
          if (currentQuestion.inputType == 'seconds')
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                children: [
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
                  if (_isTimerRunning)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        '$_seconds seconds',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4e3f8a),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Students List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                final student = widget.students[index];
                return StudentScoreCard(
                  student: student,
                  question: currentQuestion,
                  questionIndex: _currentQuestionIndex,
                  currentTimerValue: _seconds,
                  onScoreChanged: (score) {
                    setState(() {
                      (_allResponses[student.id] as Map<String, dynamic>)[
                          'response$_currentQuestionIndex'] = score;
                    });
                  },
                  onMarkAbsent: () => _markStudentAbsent(student),
                  initialValue: (_allResponses[student.id] as Map<String,
                      dynamic>)['response$_currentQuestionIndex'],
                );
              },
            ),
          ),

          // Navigation Buttons
          Container(
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
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Check if all students have scores for current question
                      bool allAnswered = true;
                      for (var student in widget.students) {
                        final responses =
                            _allResponses[student.id] as Map<String, dynamic>;
                        if (!responses
                            .containsKey('response$_currentQuestionIndex')) {
                          allAnswered = false;
                          break;
                        }
                      }

                      if (!allAnswered) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please score all students before proceeding'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      _nextQuestion();
                    },
                    icon: Icon(
                      _currentQuestionIndex == _questions.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                    ),
                    label: Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Save All'
                          : 'Next Question',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudentScoreCard extends StatefulWidget {
  final StudentModel student;
  final AssessmentQuestionModel question;
  final int questionIndex;
  final int currentTimerValue;
  final Function(dynamic) onScoreChanged;
  final VoidCallback onMarkAbsent;
  final dynamic initialValue;

  const StudentScoreCard({
    Key? key,
    required this.student,
    required this.question,
    required this.questionIndex,
    required this.currentTimerValue,
    required this.onScoreChanged,
    required this.onMarkAbsent,
    this.initialValue,
  }) : super(key: key);

  @override
  State<StudentScoreCard> createState() => _StudentScoreCardState();
}

class _StudentScoreCardState extends State<StudentScoreCard> {
  late TextEditingController _controller;

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
    super.dispose();
  }

  void _useTimerValue() {
    _controller.text = widget.currentTimerValue.toString();
    widget.onScoreChanged(widget.currentTimerValue);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Student Info
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

            // Score Input
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controller,
                keyboardType: widget.question.inputType == 'integer'
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  suffixText: widget.question.inputType == 'seconds' ? 's' : '',
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

            // Quick Actions
            const SizedBox(width: 8),
            Column(
              children: [
                if (widget.question.inputType == 'seconds')
                  IconButton(
                    icon: const Icon(Icons.timer, size: 20),
                    onPressed: _useTimerValue,
                    tooltip: 'Use timer value',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                IconButton(
                  icon: const Icon(Icons.block, size: 20, color: Colors.red),
                  onPressed: widget.onMarkAbsent,
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
  }
}
