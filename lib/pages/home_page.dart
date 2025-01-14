import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:study_tracker_frontend/components/add_exam_modal.dart';
import 'package:study_tracker_frontend/components/edit_exam_modal.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Modal para adicionar prova
  void _showAddExamModal(BuildContext context, String? userId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AddExamModal(userId: userId);
      },
    );
  }

  // Modal para editar prova
  void _showEditExamModal(
      BuildContext context, String? userId, Map<String, dynamic> exam) {
    showDialog(
      context: context,
      builder: (ctx) {
        return EditExamModal(
          userId: userId ?? '',
          examId: exam['examId'],
          currentName: exam['name'],
          currentTotalWeight: exam['totalWeight'].toString(),
        );
      },
    );
  }

  // Converte o tempo em segundos para um formato "X h Y min"
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

  // Constrói o card do exame com o novo layout
  Widget _buildExamCard(
    BuildContext context,
    Map<String, dynamic> exam,
    String? userId,
    AuthProvider authProvider,
  ) {
    final subjects = exam['subjects'] as List? ?? [];

    return Slidable(
      key: ValueKey(exam['examId']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          // Botão de edição
          SlidableAction(
            onPressed: (context) {
              _showEditExamModal(context, userId, exam);
            },
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
          ),
          // Botão de exclusão
          SlidableAction(
            onPressed: (context) async {
              final confirm = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    "Confirmação",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content:
                      const Text("Tem certeza que deseja remover esta prova?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text("Remover"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await authProvider.deleteExam(userId, exam['examId']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Prova removida com sucesso!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Erro ao remover a prova."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Excluir',
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/exam-details',
            arguments: {
              'examId': exam['examId'],
              'userId': userId,
              'name': exam['name'],
              'subjects': exam['subjects'],
            },
          );
        },
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header do card
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF9900CC),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  exam['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Row(
                  children: [
                    const Icon(
                      Icons.scale_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Peso total: ${exam['totalWeight']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
              // Lista de matérias, se houver
              if (subjects.isNotEmpty) ...[
                const Divider(height: 1, color: Colors.grey),
                for (var subject in subjects)
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const Icon(
                      Icons.book_outlined,
                      color: Colors.black54,
                    ),
                    title: Text(
                      subject['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(
                          Icons.scale_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Peso: ${subject['weight']}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Estudado: ${_formatStudyTime(subject['studyTime'] + subject['dailyStudyTime'])}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color(0xFF9900CC);

    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, child) {
        final exams = authProvider.currentUser?.exams ?? [];
        final userId = authProvider.currentUser?.id;
        final totalStudySeconds = authProvider.totalStudySeconds;

        String _formatStudyTimeAppBar(int totalSeconds) {
          final hours = totalSeconds ~/ 3600;
          final minutes = (totalSeconds % 3600) ~/ 60;
          if (hours > 0) {
            return '$hours h ${minutes} min';
          } else {
            return '${minutes} min';
          }
        }

        return Scaffold(
          backgroundColor: themeColor,
          appBar: AppBar(
            backgroundColor: themeColor,
            centerTitle: true,
            elevation: 0,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Provas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Tempo Total Estudado: ${_formatStudyTimeAppBar(totalStudySeconds)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.school,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  size: 26,
                  color: Colors.white,
                ),
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExamModal(context, userId),
            backgroundColor: Colors.white,
            icon: Icon(Icons.add, color: themeColor),
            label: Text(
              'Nova Prova',
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: exams.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma prova cadastrada.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: exams.length,
                    itemBuilder: (ctx, index) {
                      final exam = exams[index];
                      return _buildExamCard(
                          context, exam, userId, authProvider);
                    },
                  ),
          ),
        );
      },
    );
  }
}
