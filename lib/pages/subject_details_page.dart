import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_tracker_frontend/pages/timer_page.dart';
import '../models/subject.dart';
import '../providers/auth_provider.dart';

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

  String _formatStudyTime(double secondsValue) {
    final totalSeconds = secondsValue.toInt();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours == 0 && minutes == 0) return '0 min';
    return '${hours}h ${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade600,
        title: Text(
          subject.name,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Confirmação"),
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
                      userId, examId, subject.subjectId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Disciplina removida com sucesso!")),
                  );
                  Navigator.of(context).pop();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Erro ao remover disciplina.")),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Container(
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes da Disciplina',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'ID',
                    value: subject.subjectId,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.book_outlined,
                    label: 'Nome',
                    value: subject.name,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.line_weight,
                    label: 'Peso',
                    value: '${subject.weight}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.star_border,
                    label: 'Importância Relativa',
                    value: '${subject.relativeImportance.toStringAsFixed(2)}%',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.public,
                    label: 'Importância Global',
                    value: '${subject.globalImportance.toStringAsFixed(2)}%',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.timer_outlined,
                    label: 'Horas Totais de Estudo',
                    value: _formatStudyTime(subject.studyTime),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.schedule,
                    label: 'Horas Diárias de Estudo',
                    value: _formatStudyTime(subject.dailyStudyTime),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FloatingActionButton(
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
          backgroundColor: Colors.deepPurple.shade600,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: const Text(
            'Timer',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepPurple.shade600, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: Colors.deepPurple.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
