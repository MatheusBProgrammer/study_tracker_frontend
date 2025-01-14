import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  /// Converte segundos em "X h Y min".
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
    final examArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final examId = examArgs['examId'] as String;
    final userId = examArgs['userId'] as String;
    final examName = examArgs['name'] as String;

    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, child) {
        if (authProvider.currentUser == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Nenhum usuário logado',
                style: TextStyle(
                  color: const Color(0xFF9900CC),
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        final exams = authProvider.currentUser!.exams;
        final currentExam = exams.firstWhere(
          (e) => e['examId'] == examId,
          orElse: () => null,
        );

        // Se não encontrar esse exame no array do usuário:
        if (currentExam == null) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFF9900CC),
              iconTheme: const IconThemeData(color: Colors.white),
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
            backgroundColor: const Color(0xFF9900CC),
            body: Center(
              child: Text(
                'Exame não encontrado.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        final List subjects = currentExam['subjects'] ?? [];

        return Scaffold(
          // Fundo roxo para toda a tela
          backgroundColor: const Color(0xFF9900CC),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF9900CC),
            iconTheme: const IconThemeData(color: Colors.white),
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
            backgroundColor: Colors.white,
            icon: const Icon(Icons.add, color: Color(0xFF9900CC)),
            label: const Text(
              'Nova Disciplina',
              style: TextStyle(
                color: Color(0xFF9900CC),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Área de conteúdo
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent, // Mantém o fundo roxo
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                color: Colors.white, // Área branca para contraste
                child: subjects.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma disciplina cadastrada.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: subjects.length,
                        itemBuilder: (ctx, index) {
                          final subject = Subject.fromJson(subjects[index]);
                          final double totalStudySeconds =
                              subject.studyTime + subject.dailyStudyTime;
                          final formattedStudyTime =
                              _formatStudyTime(totalStudySeconds);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Slidable(
                              key: ValueKey(subject.subjectId),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  // Botão Editar
                                  SlidableAction(
                                    onPressed: (context) {
                                      // Lógica para editar a disciplina (à implementar)
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Função de editar não implementada."),
                                        ),
                                      );
                                    },
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Editar',
                                  ),
                                  // Botão Apagar
                                  SlidableAction(
                                    onPressed: (context) async {
                                      final confirm = await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          title: const Text("Confirmação"),
                                          content: const Text(
                                            "Deseja remover esta disciplina?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text("Cancelar"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text("Remover"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await authProvider.deleteSubject(
                                            userId,
                                            examId,
                                            subject.subjectId,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Disciplina removida com sucesso!"),
                                            ),
                                          );
                                        } catch (error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Erro ao remover a disciplina."),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Apagar',
                                  ),
                                ],
                              ),
                              child: Card(
                                color: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: ListTile(
                                  onTap: () {
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
                                  leading: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xFF9900CC)
                                        .withOpacity(0.9),
                                    child: const Icon(
                                      Icons.book,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  title: Text(
                                    subject.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.scale_outlined,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Peso: ${subject.weight}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_outlined,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Estudado: $formattedStudyTime',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.flag_outlined,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Meta: ${subject.studyGoal.toInt()} horas',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
