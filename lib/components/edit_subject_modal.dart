import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/auth_provider.dart';

class EditSubjectModal extends StatefulWidget {
  final String userId;
  final String examId;
  final Subject subject;

  const EditSubjectModal({
    Key? key,
    required this.userId,
    required this.examId,
    required this.subject,
  }) : super(key: key);

  @override
  State<EditSubjectModal> createState() => _EditSubjectModalState();
}

class _EditSubjectModalState extends State<EditSubjectModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _studyGoalController; // se desejar editar a meta

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject.name);
    _weightController =
        TextEditingController(text: widget.subject.weight.toString());
    _studyGoalController = TextEditingController(
      text: widget.subject.studyGoal != null
          ? widget.subject.studyGoal.toString()
          : '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _studyGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController.text.trim();
      final newWeight = double.tryParse(_weightController.text);
      final newStudyGoal = double.tryParse(_studyGoalController.text);

      if (newWeight == null || newWeight < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Peso inválido. Informe um número maior ou igual a zero.'),
          ),
        );
        return;
      }

      if (newStudyGoal == null || newStudyGoal < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Meta inválida. Informe um número maior ou igual a zero.'),
          ),
        );
        return;
      }

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateSubject(
          userId: widget.userId,
          examId: widget.examId,
          subjectId: widget.subject.subjectId,
          name: newName,
          weight: newWeight,
          studyGoal: newStudyGoal,
        );
        Navigator.of(context).pop(); // Fecha o modal
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar a disciplina.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Disciplina'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o nome da disciplina';
                    }
                    return null;
                  },
                ),
                // Peso
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Peso'),
                  keyboardType: TextInputType.number,
                ),
                // Meta de estudo (em horas)
                TextFormField(
                  controller: _studyGoalController,
                  decoration: const InputDecoration(
                    labelText: 'Meta de estudo (em horas)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          onPressed: _saveChanges,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
