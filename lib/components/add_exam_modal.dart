import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AddExamModal extends StatefulWidget {
  final String? userId;

  const AddExamModal({super.key, required this.userId});

  @override
  State<AddExamModal> createState() => _AddExamModalState();
}

class _AddExamModalState extends State<AddExamModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalWeightController = TextEditingController();
  bool _isLoading = false;

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
  Widget build(BuildContext context) {
    return AlertDialog(
      // ------------------ DIÁLOGO ESTILIZADO ------------------
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Colors.deepPurple.shade50, // Fundo suave

      // ------------------ TÍTULO ------------------
      title: Row(
        children: [
          Icon(
            Icons.add_circle_outline,
            color: Colors.deepPurple.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            'Adicionar Prova',
            style: TextStyle(
              color: Colors.deepPurple.shade700,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      // ------------------ CONTEÚDO ------------------
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo "Nome da Prova"
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Prova',
                labelStyle: TextStyle(
                  color: Colors.deepPurple.shade700,
                ),
                hintText: 'Ex.: Prova de Matemática',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade300),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Campo "Peso Total"
            TextField(
              controller: _totalWeightController,
              decoration: InputDecoration(
                labelText: 'Peso Total',
                labelStyle: TextStyle(
                  color: Colors.deepPurple.shade700,
                ),
                hintText: 'Ex.: 100',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade300),
                ),
                helperText:
                    'Informe quantos pontos a prova terá ao todo (Ex.: 100).',
                helperStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.deepPurple.shade400,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 16),

            // Texto explicativo adicional (opcional)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'O “Peso Total” representa quantos pontos ou qual a pontuação máxima que esta prova valerá. Posteriormente, você poderá cadastrar disciplinas (matérias) e definir o peso de cada uma delas dentro desta prova.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.deepPurple.shade900,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),

      // ------------------ BOTÕES DE AÇÃO ------------------
      actions: [
        // Botão de Cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepPurple.shade600,
          ),
          child: const Text('Cancelar'),
        ),

        // Botão de Adicionar ou Loader
        _isLoading
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _addExam,
                child: const Text(
                  'Adicionar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ],
    );
  }
}
