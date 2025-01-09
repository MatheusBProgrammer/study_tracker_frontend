class Subject {
  final String subjectId;
  final String name;
  final double weight;
  final double relativeImportance;
  final double globalImportance;
  final double studyTime;
  final double dailyStudyTime;

  Subject({
    required this.subjectId,
    required this.name,
    required this.weight,
    required this.relativeImportance,
    required this.globalImportance,
    required this.studyTime,
    required this.dailyStudyTime,
  });

  // Converte de JSON para objeto
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'],
      name: json['name'],
      weight: json['weight'].toDouble(),
      relativeImportance: json['relativeImportance'].toDouble(),
      globalImportance: json['globalImportance'].toDouble(),
      studyTime: json['studyTime'].toDouble(),
      dailyStudyTime: json['dailyStudyTime'].toDouble(),
    );
  }

  // Converte de objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'name': name,
      'weight': weight,
      'relativeImportance': relativeImportance,
      'globalImportance': globalImportance,
      'studyTime': studyTime,
      'dailyStudyTime': dailyStudyTime,
    };
  }
}
