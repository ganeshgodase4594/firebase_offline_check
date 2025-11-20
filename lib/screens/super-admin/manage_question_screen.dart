// lib/screens/super_admin/manage_questions_screen.dart
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:flutter/material.dart';
import '../../models/assessment_question_model.dart';
import 'edit_question_screen.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final int level;

  const ManageQuestionsScreen({Key? key, required this.level})
      : super(key: key);

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  List<AssessmentQuestionModel> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    FirebaseService.getQuestionsByLevelStream(widget.level).listen((questions) {
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _deleteQuestion(AssessmentQuestionModel question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: Text(
            'Are you sure you want to delete this question?\n\n"${question.questionText}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseService.deleteAssessmentQuestion(question.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting question: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level} Questions'),
      ),
      floatingActionButton: _questions.length < 6
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditQuestionScreen(
                      level: widget.level,
                      questionNumber: _questions.length,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
              backgroundColor: const Color(0xFF4e3f8a),
            )
          : null,
      body: Column(
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Level ${widget.level} requires 6 questions (${_questions.length}/6 added)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Questions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _questions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No questions added yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditQuestionScreen(
                                      level: widget.level,
                                      questionNumber: 0,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Question'),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _questions.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }

                          setState(() {
                            final item = _questions.removeAt(oldIndex);
                            _questions.insert(newIndex, item);
                          });

                          // Update order in Firebase
                          for (int i = 0; i < _questions.length; i++) {
                            await FirebaseService.updateAssessmentQuestion(
                              _questions[i].id,
                              {'order': i, 'questionNumber': i},
                            );
                          }
                        },
                        itemBuilder: (context, index) {
                          final question = _questions[index];
                          return Card(
                            key: ValueKey(question.id),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF4e3f8a),
                                child: Text(
                                  'Q${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                question.questionText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Input Type: ${question.inputType}'),
                                  if (question.presetTimer != null)
                                    Text(
                                        'Timer: ${question.presetTimer} seconds'),
                                  if (question.videoUrl != null)
                                    const Text('📹 Has demo video'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditQuestionScreen(
                                            level: widget.level,
                                            questionNumber: index,
                                            existingQuestion: question,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteQuestion(question),
                                  ),
                                  const Icon(Icons.drag_handle),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
