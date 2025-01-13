import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_tracker_frontend/components/add_exam_modal.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showAddExamModal(BuildContext context, String? userId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AddExamModal(userId: userId);
      },
    );
  }

  /// Converte o valor de [totalSeconds] em um texto no formato "X h Y min".
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

  /// Constrói o Card de um único exame, incluindo a lista de matérias (subjects).
  Widget _buildExamCard(BuildContext context, Map<String, dynamic> exam,
      String? userId, AuthProvider authProvider) {
    // Lista de matérias do exame
    final subjects = exam['subjects'] as List? ?? [];

    return Slidable(
      key: ValueKey(exam['examId']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              final confirm = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Confirmação"),
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
                        content: Text("Prova removida com sucesso!")),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erro ao remover a prova.")),
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
      child: InkWell(
        onTap: () {
          // Ao clicar no Card principal, abre a tela de detalhes do exame (se desejar)
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
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              // Gradiente de fundo para o Card
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade100.withOpacity(0.4),
                  Colors.deepPurple.shade50.withOpacity(0.5),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------- ListTile principal do Exame ----------
                ListTile(
                  // Ícone circular com gradiente
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
                    ),
                  ),
                  // Exemplo de "Peso total" (caso queira exibir do exame)
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.scale_outlined,
                        color: Colors.grey.shade800,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Peso total: ${exam['totalWeight']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                  ),
                ),

                // ---------- Exibe cada matéria (subject) do Exame ----------
                if (subjects.isNotEmpty) const Divider(height: 1),

                for (var subject in subjects)
                  ListTile(
                    // Ícone da matéria
                    leading: Icon(
                      Icons.book_outlined,
                      color: Colors.deepPurple.shade600,
                    ),
                    title: Text(
                      subject['name'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Ícone e peso
                        Icon(
                          Icons.scale_outlined,
                          color: Colors.grey.shade800,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Peso: ${subject['weight']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Ícone e tempo de estudo
                        Icon(
                          Icons.access_time_outlined,
                          color: Colors.grey.shade800,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        // Somamos studyTime + dailyStudyTime (ambos em segundos)
                        // se essa for a sua intenção de "tempo total".
                        Text(
                          'Estudado: ${_formatStudyTime((subject['studyTime'] + subject['dailyStudyTime']))}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, child) {
        final exams = authProvider.currentUser?.exams ?? [];
        final userId = authProvider.currentUser?.id;

        // Convertemos totalStudySeconds do usuário para exibir no AppBar
        // (caso queira exibir o total geral do usuário, por exemplo).
        final totalStudySeconds = authProvider.totalStudySeconds;

        // Caso queria exibir o total de horas estudadas do usuário no AppBar:
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
          // --------------------- APP BAR ---------------------
          appBar: AppBar(
            elevation: 0, // remove a sombra do AppBar
            backgroundColor: Colors.deepPurple.shade600,
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Provas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Exemplo de exibir o total de horas estudadas do usuário
                Text(
                  'Tempo Total Estudado: ${_formatStudyTimeAppBar(totalStudySeconds)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            leading: Container(
              margin: const EdgeInsets.only(left: 12),
              child: const Icon(
                Icons.school,
                size: 28,
                color: Colors.white,
              ),
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

          // --------------------- FLOATING BUTTON ---------------------
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExamModal(context, userId),
            backgroundColor: Colors.deepPurple.shade600,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              'Nova Prova',
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
            child: exams.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma prova cadastrada.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: exams.length,
                    itemBuilder: (ctx, index) {
                      final exam = exams[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        // Aqui chamamos a função que constrói o Card do exame,
                        // com as matérias dentro.
                        child:
                            _buildExamCard(context, exam, userId, authProvider),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
