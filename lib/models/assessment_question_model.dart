// lib/models/assessment_question_model.dart
class AssessmentQuestionModel {
  final String id;
  final int level;
  final int questionNumber; // 0-5
  final String questionText;
  final String inputType; // 'integer' or 'seconds'
  final String? videoUrl;
  final int? presetTimer; // in seconds (30, 60, 90)
  final int order;

  AssessmentQuestionModel({
    required this.id,
    required this.level,
    required this.questionNumber,
    required this.questionText,
    required this.inputType,
    this.videoUrl,
    this.presetTimer,
    required this.order,
  });

  factory AssessmentQuestionModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return AssessmentQuestionModel(
      id: id,
      level: data['level'] ?? 1,
      questionNumber: data['questionNumber'] ?? 0,
      questionText: data['questionText'] ?? '',
      inputType: data['inputType'] ?? 'integer',
      videoUrl: data['videoUrl'],
      presetTimer: data['presetTimer'],
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'questionNumber': questionNumber,
      'questionText': questionText,
      'inputType': inputType,
      'videoUrl': videoUrl,
      'presetTimer': presetTimer,
      'order': order,
    };
  }
}
