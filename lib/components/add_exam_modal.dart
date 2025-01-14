import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AddExamModal extends StatefulWidget {
  final String? userId;

  const AddExamModal({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddExamModal> createState() => _AddExamModalState();
}

class _AddExamModalState extends State<AddExamModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalWeightController = TextEditingController();
  bool _isLoading = false;
  final Color themeColor = const Color(0xFF9900CC);

  /// Método para retornar a InputDecoration padrão
  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    String? helper,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      labelStyle: TextStyle(
        color: themeColor.withOpacity(0.8),
        fontWeight: FontWeight.w500,
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

  Future<void> _addExam() async {
    if (_nameController.text.isEmpty || _totalWeightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url =
        'http://localhost:8080/api/exams/${widget.userId}'; // Rota da API
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'subjects': [], // Por padrão, sem disciplinas
        'totalWeight': double.parse(_totalWeightController.text),
      }),
    );

    if (response.statusCode == 200) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.fetchCurrentUser();
      Navigator.of(context).pop(true); // Fecha o modal e sinaliza sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prova adicionada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao adicionar prova')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8,
      backgroundColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título com ícone
              Row(
                children: [
                  Icon(Icons.add_circle_outline, color: themeColor),
                  const SizedBox(width: 8),
                  Text(
                    'Adicionar Prova',
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Campo "Nome da Prova"
              TextField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  label: 'Nome da Prova',
                  hint: 'Ex.: Prova de Matemática',
                ),
              ),
              const SizedBox(height: 16),
              // Campo "Peso Total"
              TextField(
                controller: _totalWeightController,
                decoration: _buildInputDecoration(
                  label: 'Peso Total',
                  hint: 'Ex.: 100',
                  helper:
                      'Informe quantos pontos a prova terá ao todo (Ex.: 100).',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: themeColor,
                    ),
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
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _addExam,
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
      ),
    );
  }
}
