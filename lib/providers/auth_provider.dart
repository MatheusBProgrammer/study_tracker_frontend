import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser; // Objeto do usuário logado
  bool _isAuthenticated = false; // Estado de autenticação
  bool _isLoading = false; // Estado de carregamento

  // Getter para verificar se o usuário está autenticado
  bool get isAuthenticated => _isAuthenticated;

  // Getter para acessar o usuário logado
  User? get currentUser => _currentUser;

  // Getter para verificar estado de carregamento
  bool get isLoading => _isLoading;

  // Armazenamos a soma de tempo de estudo (em segundos) de todas as matérias
  int _totalStudySeconds = 0;
  int get totalStudySeconds => _totalStudySeconds;

  /// Realiza o login do usuário
  Future<void> login(String email, String password) async {
    final url = Uri.parse('http://localhost:8080/api/users/login');

    _setLoading(true); // Ativa estado de carregamento

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Parse da resposta do backend e criação do objeto User
        final userData = json.decode(utf8.decode(response.bodyBytes));
        _currentUser = User.fromJson(userData);

        // Calculamos o total de estudo do usuário
        _totalStudySeconds = calculateTotalStudyHours(userData['exams']);

        _isAuthenticated = true; // Define o estado como autenticado
        notifyListeners(); // Notifica os listeners sobre a mudança no estado

        // 1) Recalcular pesos de todos os exames
        await _recalculateAllExams();

        // 2) Atualizar o _currentUser após o recálculo
        await fetchCurrentUser();
      } else {
        // Lança exceção caso o login falhe
        throw Exception('Erro ao fazer login: ${response.body}');
      }
    } catch (e) {
      // Relança a exceção para tratamento externo
      throw Exception('Erro ao se conectar ao servidor: $e');
    } finally {
      _setLoading(false); // Desativa estado de carregamento
    }
  }

  /// Realiza o logout do usuário
  void logout() {
    _currentUser = null; // Limpa os dados do usuário
    _isAuthenticated = false; // Define o estado como não autenticado
    notifyListeners(); // Notifica os listeners sobre a mudança no estado
  }

  /// Atualiza o estado de carregamento
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Notifica os listeners sobre a mudança no estado
  }

  /// Atualiza os dados do usuário após uma ação
  Future<void> fetchCurrentUser() async {
    if (_currentUser == null) return;

    final url = Uri.parse(
      'http://localhost:8080/api/users/${_currentUser!.id}',
    ); // Rota para buscar os dados do usuário

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        _currentUser = User.fromJson(userData); // Atualiza o objeto do usuário

        // Atualiza o total de estudo também
        _totalStudySeconds = calculateTotalStudyHours(userData['exams']);
        notifyListeners();
      } else {
        throw Exception('Erro ao atualizar os dados do usuário.');
      }
    } catch (e) {
      throw Exception('Erro ao se conectar ao servidor: $e');
    }
  }

  /// Recalcula a importância (relative, global) de todos os exames do usuário
  Future<void> _recalculateAllExams() async {
    if (_currentUser == null) return;

    for (final exam in _currentUser!.exams) {
      final examId = exam['examId'];
      if (examId == null) continue;

      final recalcUrl = Uri.parse(
        'http://localhost:8080/api/subjects/${_currentUser!.id}/$examId/recalculate-importance',
      );

      try {
        // Chamando o PATCH
        final response = await http.patch(
          recalcUrl,
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200) {
          debugPrint('Falha ao recalcular exame $examId: ${response.body}');
        }
      } catch (e) {
        debugPrint('Erro de conexão ao recalcular exame $examId: $e');
      }
    }
  }

  /// Função auxiliar para calcular total de estudo (em segundos) a partir de uma lista de exames
  int calculateTotalStudyHours(List<dynamic> exams) {
    int totalSeconds = 0;

    for (var exam in exams) {
      for (var subject in exam['subjects']) {
        final studyTime = subject['studyTime'] ?? 0; // Em segundos
        final dailyTime = subject['dailyStudyTime'] ?? 0; // Em segundos

        int totalForSubject = 0;

        // Pode ser que studyTime ou dailyTime venham como String ou num:
        if (studyTime is String) {
          totalForSubject += int.tryParse(studyTime) ?? 0;
        } else if (studyTime is num) {
          totalForSubject += studyTime.toInt();
        }
        if (dailyTime is String) {
          totalForSubject += int.tryParse(dailyTime) ?? 0;
        } else if (dailyTime is num) {
          totalForSubject += dailyTime.toInt();
        }

        totalSeconds += totalForSubject;
      }
    }

    return totalSeconds;
  }

  /// Deleta um exame do usuário
  Future<void> deleteExam(String? userId, String examId) async {
    if (userId == null || _currentUser == null) return;

    final url = Uri.parse(
      'http://localhost:8080/api/exams/$userId/$examId',
    );

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Remove o exame localmente
        _currentUser!.exams.removeWhere((exam) => exam['examId'] == examId);
        // Recalcula o total de estudo
        _totalStudySeconds =
            calculateTotalStudyHours(_currentUser!.exams as List<dynamic>);
        notifyListeners();
        debugPrint('Exame $examId deletado com sucesso.');
      } else {
        throw Exception('Erro ao deletar exame: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao deletar exame: $e');
      throw Exception('Erro de conexão ao deletar exame: $e');
    }
  }

  /// Excluir uma disciplina
  Future<void> deleteSubject(
    String userId,
    String examId,
    String subjectId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/subjects/$userId/$examId/$subjectId',
    );
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Remove localmente
        final exam = _currentUser?.exams.firstWhere(
          (e) => e['examId'] == examId,
          orElse: () => null,
        );
        if (exam != null) {
          (exam['subjects'] as List)
              .removeWhere((s) => s['subjectId'] == subjectId);
        }

        // Recalcula o total de estudo
        _totalStudySeconds =
            calculateTotalStudyHours(_currentUser!.exams as List<dynamic>);
        notifyListeners();
      } else {
        throw Exception('Erro ao deletar disciplina: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao deletar disciplina: $e');
      throw Exception('Erro de conexão ao deletar disciplina: $e');
    }
  }

  // -----------------------------------------------------------------
  //  A PARTIR DAQUI, AS FUNÇÕES DE EDIÇÃO (UPDATE) DE EXAME E DISCIPLINA
  // -----------------------------------------------------------------

  /// Editar um exame (PUT /api/exams/{userId}/{examId})
  Future<void> updateExam({
    required String userId,
    required String examId,
    required String name,
    required double totalWeight,
  }) async {
    final url = Uri.parse('http://localhost:8080/api/exams/$userId/$examId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'examId': examId,
          'name': name,
          'totalWeight': totalWeight,
          // Se quiser atualizar subjects, adicione aqui,
          // mas no seu backend você decide se atualiza ou não.
        }),
      );

      if (response.statusCode == 200) {
        // Atualiza localmente
        final examIndex = _currentUser?.exams.indexWhere(
          (e) => e['examId'] == examId,
        );

        if (examIndex != null && examIndex >= 0) {
          _currentUser!.exams[examIndex]['name'] = name;
          _currentUser!.exams[examIndex]['totalWeight'] = totalWeight;
        }

        // Recalcula a importância
        await _recalculateAllExams();

        // Atualiza e notifica
        await fetchCurrentUser();
        notifyListeners();
      } else {
        throw Exception('Erro ao atualizar exame: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao atualizar exame: $e');
      throw Exception('Erro de conexão ao atualizar exame: $e');
    }
  }

  /// Editar uma disciplina (PUT /api/subjects/{userId}/{examId}/{subjectId})
  Future<void> updateSubject({
    required String userId,
    required String examId,
    required String subjectId,
    required String name,
    required double weight,
    required double studyGoal,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/subjects/$userId/$examId/$subjectId',
    );

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subjectId': subjectId,
          'name': name,
          'weight': weight,
          'studyGoal': studyGoal,
        }),
      );

      if (response.statusCode == 200) {
        // Atualiza localmente
        final exam = _currentUser?.exams.firstWhere(
          (e) => e['examId'] == examId,
          orElse: () => null,
        );
        if (exam != null) {
          final subjectList = exam['subjects'] as List;
          final subjectIndex = subjectList.indexWhere(
            (s) => s['subjectId'] == subjectId,
          );
          if (subjectIndex != -1) {
            subjectList[subjectIndex]['name'] = name;
            subjectList[subjectIndex]['weight'] = weight;
            subjectList[subjectIndex]['studyGoal'] = studyGoal;
          }
        }

        // Recalcula a importância
        await _recalculateAllExams();

        // Atualiza e notifica
        await fetchCurrentUser();
        notifyListeners();
      } else {
        throw Exception('Erro ao atualizar disciplina: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao atualizar disciplina: $e');
      throw Exception('Erro de conexão ao atualizar disciplina: $e');
    }
  }
}
