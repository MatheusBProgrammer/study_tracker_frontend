import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AddSubjectModal extends StatefulWidget {
  final String examId;
  final String userId;

  const AddSubjectModal({
    Key? key,
    required this.examId,
    required this.userId,
  }) : super(key: key);

  @override
  State<AddSubjectModal> createState() => _AddSubjectModalState();
}

class _AddSubjectModalState extends State<AddSubjectModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _studyGoalController = TextEditingController();
  bool _isLoading = false;

  // Cor tema usada em todo o modal
  final Color themeColor = const Color(0xFF9900CC);

  // Função para montar a decoração dos campos de texto (TextField)
  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      labelStyle: TextStyle(
        color: themeColor.withOpacity(0.8),
        fontWeight: FontWeight.w500,
      ),
      helperStyle: TextStyle(
        fontSize: 12,
        color: themeColor.withOpacity(0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: themeColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _addSubject() async {
    if (_nameController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha ao menos o nome e o peso.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url =
        'http://localhost:8080/api/subjects/${widget.userId}/${widget.examId}';

    // Se o usuário deixar a meta em branco, definimos como 0.0
    final studyGoalValue = _studyGoalController.text.isEmpty
        ? 0.0
        : double.parse(_studyGoalController.text);

    final body = jsonEncode({
      'name': _nameController.text.trim(),
      'weight': double.parse(_weightController.text),
      'studyGoal': studyGoalValue,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.fetchCurrentUser();

        Navigator.of(context).pop(true); // Fecha o modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disciplina adicionada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar disciplina: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ------------ Título com ícone ------------
            Row(
              children: [
                Icon(Icons.add_circle_outline, color: themeColor),
                const SizedBox(width: 8),
                Text(
                  'Adicionar Disciplina',
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ------------ Campo: Nome da Disciplina ------------
            TextField(
              controller: _nameController,
              decoration: _buildInputDecoration(
                labelText: 'Nome da Disciplina',
                hintText: 'Ex.: Matemática Financeira',
              ),
            ),

            const SizedBox(height: 16),

            // ------------ Campo: Peso da Disciplina ------------
            TextField(
              controller: _weightController,
              decoration: _buildInputDecoration(
                labelText: 'Peso da Disciplina',
                hintText: 'Ex.: 40',
                helperText: 'Quanto essa disciplina vale dentro da prova.',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 16),

            // ------------ Campo: Meta de horas (opcional) ------------
            TextField(
              controller: _studyGoalController,
              decoration: _buildInputDecoration(
                labelText: 'Meta de horas',
                hintText: 'Ex.: 10 (horas)',
                helperText: 'Quanto tempo em horas você quer alcançar?',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                // Permite números e ponto decimal
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
            ),

            const SizedBox(height: 16),

            // ------------ Texto de ajuda adicional ------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'O “Peso da Disciplina” indica sua importância dentro da prova. '
                'Os valores de importância relativa e global serão recalculados de acordo '
                'com os pesos de todas as disciplinas.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 24),

            // ------------ Botões de ação ------------
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: themeColor),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _addSubject,
                        child: const Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
