// lib/screens/super_admin/edit_question_screen.dart
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:flutter/material.dart';
import '../../models/assessment_question_model.dart';

class EditQuestionScreen extends StatefulWidget {
  final int level;
  final int questionNumber;
  final AssessmentQuestionModel? existingQuestion;

  const EditQuestionScreen({
    Key? key,
    required this.level,
    required this.questionNumber,
    this.existingQuestion,
  }) : super(key: key);

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _videoUrlController = TextEditingController();

  String _inputType = 'integer';
  int? _presetTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      _questionTextController.text = widget.existingQuestion!.questionText;
      _videoUrlController.text = widget.existingQuestion!.videoUrl ?? '';
      _inputType = widget.existingQuestion!.inputType;
      _presetTimer = widget.existingQuestion!.presetTimer;
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final question = AssessmentQuestionModel(
      id: widget.existingQuestion?.id ?? '',
      level: widget.level,
      questionNumber: widget.questionNumber,
      questionText: _questionTextController.text.trim(),
      inputType: _inputType,
      videoUrl: _videoUrlController.text.trim().isEmpty
          ? null
          : _videoUrlController.text.trim(),
      presetTimer: _presetTimer,
      order: widget.questionNumber,
    );

    try {
      if (widget.existingQuestion != null) {
        // Update existing question
        await FirebaseService.updateAssessmentQuestion(
          widget.existingQuestion!.id,
          question.toFirestore(),
        );
      } else {
        // Create new question
        await FirebaseService.createAssessmentQuestion(question);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingQuestion != null
                ? 'Question updated successfully'
                : 'Question created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving question: $e'),
            backgroundColor: Colors.red,
          ),
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
        title: Text(widget.existingQuestion != null
            ? 'Edit Question'
            : 'Add New Question'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Level ${widget.level} - Question ${widget.questionNumber + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create clear, specific questions for motor skill assessment.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Question Text
            TextFormField(
              controller: _questionTextController,
              decoration: const InputDecoration(
                labelText: 'Question Text *',
                hintText: 'e.g., How many times can the child hop on one leg?',
                helperText: 'Be specific and clear',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter question text';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Input Type
            const Text(
              'Input Type *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Integer (Count)'),
              subtitle: const Text('For counting repetitions, scores, etc.'),
              value: 'integer',
              groupValue: _inputType,
              onChanged: (value) {
                setState(() {
                  _inputType = value!;
                  _presetTimer = null;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Seconds (Time)'),
              subtitle: const Text('For timing activities with stopwatch'),
              value: 'seconds',
              groupValue: _inputType,
              onChanged: (value) {
                setState(() {
                  _inputType = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Preset Timer (only for seconds type)
            if (_inputType == 'seconds') ...[
              const Text(
                'Preset Timer (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If this activity has a specific time duration, set it here:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('30s'),
                    selected: _presetTimer == 30,
                    onSelected: (selected) {
                      setState(() {
                        _presetTimer = selected ? 30 : null;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('60s'),
                    selected: _presetTimer == 60,
                    onSelected: (selected) {
                      setState(() {
                        _presetTimer = selected ? 60 : null;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('90s'),
                    selected: _presetTimer == 90,
                    onSelected: (selected) {
                      setState(() {
                        _presetTimer = selected ? 90 : null;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('No preset'),
                    selected: _presetTimer == null,
                    onSelected: (selected) {
                      setState(() {
                        _presetTimer = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Video URL
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Demo Video URL (Optional)',
                hintText: 'https://youtube.com/watch?v=...',
                helperText: 'Link to demonstration video',
                prefixIcon: Icon(Icons.video_library),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveQuestion,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.existingQuestion != null
                  ? 'Update Question'
                  : 'Create Question'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
