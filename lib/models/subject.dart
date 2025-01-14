class Subject {
  final String subjectId;
  final String name;
  final double weight;
  final double relativeImportance;
  final double globalImportance;
  final double studyTime;
  final double dailyStudyTime;
  final double studyGoal;

  Subject({
    required this.subjectId,
    required this.name,
    required this.weight,
    required this.relativeImportance,
    required this.globalImportance,
    required this.studyTime,
    required this.dailyStudyTime,
    required this.studyGoal, // Adicione
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'],
      name: json['name'],
      weight: (json['weight'] as num).toDouble(),
      relativeImportance: (json['relativeImportance'] as num).toDouble(),
      globalImportance: (json['globalImportance'] as num).toDouble(),
      studyTime: (json['studyTime'] as num).toDouble(),
      dailyStudyTime: (json['dailyStudyTime'] as num).toDouble(),
      // NOVO - Verifique se seu backend está retornando "studyGoal"
      studyGoal: (json['studyGoal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'name': name,
      'weight': weight,
      'relativeImportance': relativeImportance,
      'globalImportance': globalImportance,
      'studyTime': studyTime,
      'dailyStudyTime': dailyStudyTime,
      // NOVO
      'studyGoal': studyGoal,
    };
  }
}
