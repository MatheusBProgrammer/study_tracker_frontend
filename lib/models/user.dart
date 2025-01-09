class User {
  final String id;
  final String name;
  final String email;
  final List<dynamic> exams; // Liste as provas do usuário

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.exams,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      exams: json['exams'], // Mapeia as provas
    );
  }
}
