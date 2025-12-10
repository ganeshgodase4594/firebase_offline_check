import 'dart:async';
import 'dart:ui';
import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:brainmoto_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

// Models
enum AssessmentType {
  locomotor,
  objectControl,
  bodyManagement,
  coordination,
}

enum QuestionType {
  stopwatchStepper, // presetTimer == 0 or null
  timerStepper, // presetTimer > 0
  stepper, // inputType == "integer"
}

class AssessmentQuestion {
  final String id;
  final String questionText;
  final int? presetTimer; // null or 0 = stopwatch, >0 = countdown timer
  final String inputType; // "seconds" or "integer"
  final int level;
  final int order;
  final int questionNumber;
  final AssessmentType assessmentType;
  final String? videoUrl;

  AssessmentQuestion({
    required this.id,
    required this.questionText,
    this.presetTimer,
    required this.inputType,
    required this.level,
    required this.order,
    required this.questionNumber,
    required this.assessmentType,
    this.videoUrl,
  });

  QuestionType get type {
    if (inputType == "integer") {
      return QuestionType.stepper;
    } else if (presetTimer == null || presetTimer == 0) {
      return QuestionType.stopwatchStepper;
    } else {
      return QuestionType.timerStepper;
    }
  }

  String get assessmentTypeLabel {
    switch (assessmentType) {
      case AssessmentType.locomotor:
        return 'Locomotor';
      case AssessmentType.objectControl:
        return 'Object Control';
      case AssessmentType.bodyManagement:
        return 'Body Management';
      case AssessmentType.coordination:
        return 'Coordination';
    }
  }
}

class AssessmentQuestionScreen extends StatefulWidget {
  final String studentName;
  final String studentId;
  final int level;

  const AssessmentQuestionScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.level,
  });

  @override
  State<AssessmentQuestionScreen> createState() =>
      _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen> {
  late List<AssessmentQuestion> _questions;
  int _currentQuestionIndex = 0;
  late TextEditingController _answerController;

  // Timer/Stopwatch state
  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;

  // Stepper state
  int _stepperValue = 0;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _loadQuestions();
    _initializeQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _loadQuestions() {
    // TODO: Replace with actual API call based on level
    // For now using Figma mock data
    _questions = _getMockQuestions(widget.level);
  }

  List<AssessmentQuestion> _getMockQuestions(int level) {
    // Mock data from Figma - same questions for all students in this level
    return [
      AssessmentQuestion(
        id: 'Z4I2GVycgbZ2QiRW3aER',
        questionText: 'How many m distance can child passed in 30 sec?',
        presetTimer: 30,
        inputType: 'seconds',
        level: level,
        order: 5,
        questionNumber: 5,
        assessmentType: AssessmentType.locomotor,
      ),
      AssessmentQuestion(
        id: 'nWd908dya6TUZaRBDh5s',
        questionText: '9-3=?',
        presetTimer: null,
        inputType: 'integer',
        level: level,
        order: 3,
        questionNumber: 3,
        assessmentType: AssessmentType.coordination,
      ),
      AssessmentQuestion(
        id: 'nkKyLURqaV86XSgAEn9u',
        questionText:
            'How many hops is the child able to do in one go around the circle 41 meter diameter using their STRONGER LEG, (without touching the other leg to the ground)?',
        presetTimer: 0,
        inputType: 'seconds',
        level: level,
        order: 1,
        questionNumber: 1,
        assessmentType: AssessmentType.locomotor,
      ),
      AssessmentQuestion(
        id: 'ss18HNIOrrP6NCrppFWI',
        questionText:
            'How many seconds can the child stand on one leg while balancing?',
        presetTimer: 60,
        inputType: 'seconds',
        level: level,
        order: 2,
        questionNumber: 2,
        assessmentType: AssessmentType.bodyManagement,
      ),
      AssessmentQuestion(
        id: 'uwVxUzWZGFG2tRYkWGEg',
        questionText: 'How many times can the child catch the ball?',
        presetTimer: null,
        inputType: 'integer',
        level: level,
        order: 4,
        questionNumber: 4,
        assessmentType: AssessmentType.objectControl,
      ),
    ];
  }

  void _initializeQuestion() {
    final question = _questions[_currentQuestionIndex];
    _stopTimer();
    _seconds = 0;
    _stepperValue = 0;
    _answerController.clear();

    // For countdown timer, set initial value
    if (question.type == QuestionType.timerStepper &&
        question.presetTimer != null) {
      _seconds = question.presetTimer!;
    }
  }

  void _startTimer() {
    final question = _questions[_currentQuestionIndex];
    if (_isTimerRunning) return;

    setState(() => _isTimerRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (question.type == QuestionType.stopwatchStepper) {
          // Stopwatch: count up
          _seconds++;
        } else if (question.type == QuestionType.timerStepper) {
          // Countdown: count down
          if (_seconds > 0) {
            _seconds--;
          } else {
            _stopTimer();
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    final question = _questions[_currentQuestionIndex];
    setState(() {
      if (question.type == QuestionType.timerStepper &&
          question.presetTimer != null) {
        _seconds = question.presetTimer!;
      } else {
        _seconds = 0;
      }
    });
  }

  void _incrementStepper() {
    setState(() => _stepperValue++);
  }

  void _decrementStepper() {
    if (_stepperValue > 0) {
      setState(() => _stepperValue--);
    }
  }

  void _saveAndNext() {
    // TODO: Save answer to backend
    final question = _questions[_currentQuestionIndex];
    final answer = {
      'questionId': question.id,
      'studentId': widget.studentId,
      'level': widget.level,
      'assessmentType': question.assessmentType.toString(),
      'timerValue': _seconds,
      'stepperValue': _stepperValue,
      'questionType': question.type.toString(),
    };

    debugPrint('Saving answer: $answer');

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _initializeQuestion();
      });
    } else {
      // Last question - show success dialog
      _showSubmitDialog();
    }
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with Animation
                Image.asset(AssetConstant.popUpImage),
                SizedBox(height: 3.hp),
                // Dashed line separator
                Container(
                  width: double.infinity,
                  height: .5.wp,
                  color:
                      AppColors.enabledButtonGradientEnd.withValues(alpha: 0.1),
                ),
                SizedBox(height: 3.hp),
                // Title
                Text(
                  'Assessment Submitted',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                // Subtitle
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.secondary.copyWith(fontSize: 14),
                    children: [
                      TextSpan(
                          text: 'Assessment of ',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryText, fontSize: 14)),
                      TextSpan(
                        text:
                            "${widget.studentName} - ", // student ID highlighted
                        style: AppTextStyles.secondary.copyWith(
                          fontSize: 14,
                          color: AppColors.enabledButtonGradientEnd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: widget.studentId, // student ID highlighted
                        style: AppTextStyles.secondary.copyWith(
                          fontSize: 14,
                          color: AppColors.enabledButtonGradientEnd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                          text: ' is submitted successfully',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryText, fontSize: 14)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')} : ${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: '${widget.studentName} (${widget.studentId})',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            SizedBox(height: 2.hp),
            _buildAssessmentTypeBadge(question),
            SizedBox(height: 3.hp),
            _buildQuestionSection(question),
            SizedBox(height: 3.hp),
            _buildInteractionSection(question),
            SizedBox(height: 3.hp),
            _buildAnswerSection(question),
            // SizedBox(height: 4.hp),

            //_buildActionButtons(),
          ],
        ),
      ),
      floatingActionButton: _buildActionButtons(),
    );
  }

  // Widget _buildProgressIndicator() {
  //   final progress = (_currentQuestionIndex + 1) / _questions.length;

  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             '${StringConstant.questionText} ${_currentQuestionIndex + 1}/${_questions.length}',
  //             style: AppTextStyles.secondary,
  //           ),
  //           Text(
  //             '${(progress * 100).toInt()}%',
  //             style: AppTextStyles.secondary.copyWith(
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 1.hp),
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(10),
  //         child: LinearProgressIndicator(

  //           value: progress,
  //           backgroundColor: AppColors.progressBarBack,
  //           valueColor: AlwaysStoppedAnimation<Color>(
  //             AppColors.success,
  //           ),
  //           minHeight: 12,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildProgressIndicator() {
    final totalQuestions = _questions.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${StringConstant.questionText} ${_currentQuestionIndex + 1}/$totalQuestions',
              style: AppTextStyles.secondary,
            ),
            Text(
              '${((_currentQuestionIndex + 1) / totalQuestions * 100).toInt()}%',
              style: AppTextStyles.secondary.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.hp),
        Row(
          children: List.generate(
            totalQuestions,
            (index) => Expanded(
              child: Container(
                height: 12,
                margin: EdgeInsets.only(
                  right: index < totalQuestions - 1 ? 2 : 0,
                ),
                decoration: BoxDecoration(
                  color: index <= _currentQuestionIndex
                      ? AppColors.success
                      : AppColors.progressBarBack,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentTypeBadge(AssessmentQuestion question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.enabledButtonGradientStart.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.inputFieldBorder,
          width: 1,
        ),
      ),
      child: Text(
        question.assessmentTypeLabel,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.enabledButtonGradientEnd,
        ),
      ),
    );
  }

  Widget _buildQuestionSection(AssessmentQuestion question) {
    return Container(
      padding: EdgeInsets.all(3.wp),
      decoration: BoxDecoration(
        color: AppColors.timerDisplayBack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputFieldBorder),
      ),
      child: Text(question.questionText,
          style: AppTextStyles.h4.copyWith(fontSize: 18)),
    );
  }

  Widget _buildInteractionSection(AssessmentQuestion question) {
    switch (question.type) {
      case QuestionType.stopwatchStepper:
        return _buildStopwatchSection();
      case QuestionType.timerStepper:
        return _buildTimerSection();
      case QuestionType.stepper:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStopwatchSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerButton(
              label: _isTimerRunning
                  ? StringConstant.stopText
                  : StringConstant.startText,
              color: _isTimerRunning
                  ? AppColors.error
                  : AppColors.countinueTextColor,
              onPressed: _isTimerRunning ? _stopTimer : _startTimer,
            ),
            SizedBox(width: 3.wp),
            _buildTimerDisplay(),
            SizedBox(width: 3.wp),
            _buildTimerButton(
              label: StringConstant.restartText,
              color: AppColors.pendingTextColor,
              onPressed: _resetTimer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerButton(
              label: _isTimerRunning
                  ? StringConstant.stopText
                  : StringConstant.startText,
              color: _isTimerRunning
                  ? AppColors.error
                  : AppColors.countinueTextColor,
              onPressed: _isTimerRunning ? _stopTimer : _startTimer,
            ),
            SizedBox(width: 3.wp),
            _buildTimerDisplay(),
            SizedBox(width: 3.wp),
            _buildTimerButton(
              label: StringConstant.restartText,
              color: AppColors.pendingTextColor,
              onPressed: _resetTimer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.wp, vertical: 1.hp),
      decoration: BoxDecoration(
          color: AppColors.timerDisplayBack,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputFieldBorder)),
      child: Text(
        _formatTime(_seconds),
        style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _buildTimerButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        // padding: EdgeInsets.symmetric(horizontal: 4.wp, vertical: 1.hp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label,
          style: AppTextStyles.nameStyle.copyWith(color: AppColors.background)),
    );
  }

  Widget _buildAnswerSection(AssessmentQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answer:',
          style: AppTextStyles.bodyMedium,
        ),
        SizedBox(height: 1.5.hp),
        Row(
          children: [
            _buildStepperButton(
              icon: Icons.remove,
              onPressed: _decrementStepper,
            ),
            SizedBox(width: 3.wp),
            Expanded(child: _buildAnswerInput(question)),
            SizedBox(width: 3.wp),
            _buildStepperButton(
              icon: Icons.add,
              onPressed: _incrementStepper,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.enabledButtonGradientEnd,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 24,
      ),
    );
  }

  Widget _buildAnswerInput(AssessmentQuestion question) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.wp, vertical: 0.5.hp),
      decoration: BoxDecoration(
        color: AppColors.timerDisplayBack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputFieldBorder),
      ),
      child: TextField(
        controller: _answerController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppTextStyles.h4,
        decoration: InputDecoration(
          hintText: StringConstant.answerHintText,
          hintStyle: AppTextStyles.secondary.copyWith(
            color: AppColors.searchBarText,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 1.hp),
        ),
        onChanged: (value) {
          // Update stepper value when user types
          final parsedValue = int.tryParse(value);
          if (parsedValue != null) {
            setState(() {
              _stepperValue = parsedValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Spacer(),
        InkWell(
          onTap: _saveAndNext,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.hp, horizontal: 2.wp),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.enabledButtonGradientStart,
                  AppColors.enabledButtonGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? StringConstant.saveAndNextText
                        : StringConstant.submitText,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.white)),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
