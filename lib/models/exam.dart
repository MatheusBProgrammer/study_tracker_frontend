import 'subject.dart';

class Exam {
  final String examId;
  final String name;
  final double totalWeight;
  final List<Subject> subjects;

  Exam({
    required this.examId,
    required this.name,
    required this.totalWeight,
    required this.subjects,
  });

  // Converte de JSON para objeto
  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      examId: json['examId'],
      name: json['name'],
      totalWeight: json['totalWeight'].toDouble(),
      subjects: (json['subjects'] as List<dynamic>)
          .map((subjectJson) => Subject.fromJson(subjectJson))
          .toList(),
    );
  }

  // Converte de objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'name': name,
      'totalWeight': totalWeight,
      'subjects': subjects.map((subject) => subject.toJson()).toList(),
    };
  }
}
