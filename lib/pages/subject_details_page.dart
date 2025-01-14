import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_tracker_frontend/pages/timer_page.dart';
import '../models/subject.dart';
import '../providers/auth_provider.dart';
import 'package:study_tracker_frontend/components/edit_subject_modal.dart'; // NOVO

class SubjectDetailsPage extends StatelessWidget {
  final Subject subject;
  final String userId;
  final String examId;

  const SubjectDetailsPage({
    Key? key,
    required this.subject,
    required this.userId,
    required this.examId,
  }) : super(key: key);

  /// Converte segundos para o formato "Xh Ymin".
  String _formatStudyTime(double secondsValue) {
    final totalSeconds = secondsValue.toInt();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours == 0 && minutes == 0) return '0 min';
    return '${hours}h ${minutes}min';
  }

  /// Calcula o % de horas estudadas em relação à meta.
  /// Ex: se studyTime = 4h e studyGoal = 8h => 50%.
  String _calculateStudyProgress(Subject subject) {
    if (subject.studyGoal <= 0) return '0%';
    // Converte studyTime (segundos) em horas
    final totalHoursStudied = subject.studyTime / 3600.0;
    final progress = (totalHoursStudied / subject.studyGoal) * 100;
    // Arredonda para 1 casa decimal
    return '${progress.toStringAsFixed(1)}%';
  }

  /// Abre o modal para editar a disciplina
  void _showEditSubjectModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return EditSubjectModal(
          userId: userId,
          examId: examId,
          subject: subject,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF9900CC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9900CC),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Disciplina",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // ------------ Botão: Editar ------------
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showEditSubjectModal(context),
          ),
          // ------------ Botão: Deletar ------------
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
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
                  content: const Text("Deseja remover esta disciplina?"),
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
                  await authProvider.deleteSubject(
                    userId,
                    examId,
                    subject.subjectId,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Disciplina removida com sucesso!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop(); // Volta para a tela anterior
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Erro ao remover disciplina."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da disciplina
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontSize: 22,
                      color: const Color(0xFF9900CC).withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 24,
                    thickness: 1,
                  ),
                  // Detalhes: Peso, Importância, etc.
                  _buildDetailRow(
                    icon: Icons.line_weight,
                    label: 'Peso',
                    value: '${subject.weight}',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.star_border,
                    label: 'Importância Relativa',
                    value: '${subject.relativeImportance.toStringAsFixed(2)}%',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.public,
                    label: 'Importância Global',
                    value: '${subject.globalImportance.toStringAsFixed(2)}%',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.timer_outlined,
                    label: 'Horas Totais de Estudo',
                    value: _formatStudyTime(subject.studyTime),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.schedule,
                    label: 'Horas Diárias de Estudo',
                    value: _formatStudyTime(subject.dailyStudyTime),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.flag_outlined,
                    label: 'Meta de Horas',
                    value: '${subject.studyGoal.toInt()} horas',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.percent,
                    label: 'Progresso',
                    value: _calculateStudyProgress(subject),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TimerPage(
                userId: userId,
                examId: examId,
                subjectId: subject.subjectId,
              ),
            ),
          );
        },
        backgroundColor: Colors.white,
        icon: const Icon(Icons.timer, color: Color(0xFF9900CC)),
        label: const Text(
          'Timer',
          style: TextStyle(
            color: Color(0xFF9900CC),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Monta cada linha de detalhe, com ícone + label (em negrito) + valor.
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF9900CC),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9900CC),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
