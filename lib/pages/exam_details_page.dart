import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_tracker_frontend/components/add_subject_modal.dart';
import 'package:study_tracker_frontend/pages/subject_details_page.dart';
import '../models/subject.dart';
import '../providers/auth_provider.dart';

class ExamDetailsPage extends StatelessWidget {
  const ExamDetailsPage({super.key});

  void _showAddSubjectModal(
      BuildContext context, String examId, String userId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AddSubjectModal(examId: examId, userId: userId);
      },
    );
  }

  /// Formata o tempo de estudo (em segundos) para "X h Y min".
  String _formatStudyTime(double totalSeconds) {
    final totalInt = totalSeconds.toInt();
    final hours = totalInt ~/ 3600;
    final minutes = (totalInt % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h ${minutes} min';
    } else {
      return '${minutes} min';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pegamos o Map enviado pelo Navigator.pushNamed:
    final examArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final examId = examArgs['examId'] as String;
    final userId = examArgs['userId'] as String;
    final examName = examArgs['name'] as String;

    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, child) {
        // Se não houver usuário logado ou o currentUser for nulo
        if (authProvider.currentUser == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Nenhum usuário logado',
                style: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        // Pegar a lista de exames atualizada do usuário
        final exams = authProvider.currentUser!.exams;

        // Localiza o exame cujo 'examId' corresponde ao examId
        final currentExam = exams.firstWhere(
          (e) => e['examId'] == examId,
          orElse: () => null,
        );

        // Caso não encontre, exibe mensagem
        if (currentExam == null) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.deepPurple.shade600,
              centerTitle: true,
              title: Text(
                examName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(
              child: Text(
                'Exame não encontrado.',
                style: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        // Lista de disciplinas do exame
        final List subjects = currentExam['subjects'] ?? [];

        return Scaffold(
          // --------------------- APP BAR ---------------------
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.deepPurple.shade600,
            centerTitle: true,
            title: Text(
              examName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // --------------------- FLOATING BUTTON ---------------------
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (examId.isEmpty || userId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao carregar IDs necessários.'),
                  ),
                );
                return;
              }
              _showAddSubjectModal(context, examId, userId);
            },
            backgroundColor: Colors.deepPurple.shade600,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'Nova Disciplina',
              style: TextStyle(color: Colors.white),
            ),
          ),

          // --------------------- CORPO/CONTEÚDO ---------------------
          body: Container(
            // Fundo com um gradiente suave
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: subjects.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma disciplina cadastrada.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: subjects.length,
                    itemBuilder: (ctx, index) {
                      final subject = Subject.fromJson(subjects[index]);

                      // Calculamos o total de estudo (studyTime + dailyStudyTime)
                      final double totalStudySeconds =
                          subject.studyTime + subject.dailyStudyTime;
                      final formattedStudyTime =
                          _formatStudyTime(totalStudySeconds);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            // Aqui passamos userId e examId para o SubjectDetailsPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => SubjectDetailsPage(
                                  subject: subject,
                                  userId: userId,
                                  examId: examId,
                                ),
                              ),
                            );
                          },
                          // Card com design arredondado e leve sombra
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepPurple.shade100.withOpacity(0.4),
                                    Colors.deepPurple.shade50.withOpacity(0.5),
                                  ],
                                ),
                              ),
                              // ListTile estilizado
                              child: ListTile(
                                // Ícone circular
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.shade400,
                                        Colors.deepPurple.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                // Nome da Disciplina
                                title: Text(
                                  subject.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Exibe o peso e o total de horas estudadas (formatadas)
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.scale_outlined,
                                          color: Colors.grey.shade800,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Peso: ${subject.weight}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_outlined,
                                          color: Colors.grey.shade800,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Estudado: $formattedStudyTime',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
