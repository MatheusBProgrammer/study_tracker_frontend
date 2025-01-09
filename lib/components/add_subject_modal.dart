import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AddSubjectModal extends StatefulWidget {
  final String examId;
  final String userId;

  const AddSubjectModal({
    super.key,
    required this.examId,
    required this.userId,
  });

  @override
  State<AddSubjectModal> createState() => _AddSubjectModalState();
}

class _AddSubjectModalState extends State<AddSubjectModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addSubject() async {
    if (_nameController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url =
        'http://localhost:8080/api/subjects/${widget.userId}/${widget.examId}';
    final body = jsonEncode({
      'name': _nameController.text,
      'weight': double.parse(_weightController.text),
    });

    print('URL: $url');
    print('JSON enviado: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

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
    return AlertDialog(
      // Moldura levemente arredondada
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // Fundo em tom de roxo clarinho
      backgroundColor: Colors.deepPurple.shade50,

      // ------------------- Cabeçalho / Título -------------------
      title: Row(
        children: [
          Icon(
            Icons.add_circle_outline,
            color: Colors.deepPurple.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            'Adicionar Disciplina',
            style: TextStyle(
              color: Colors.deepPurple.shade700,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      // ------------------- Conteúdo do Modal -------------------
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo: Nome da Disciplina
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome da Disciplina',
                labelStyle: TextStyle(
                  color: Colors.deepPurple.shade700,
                ),
                hintText: 'Ex.: Matemática Financeira',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Peso da Disciplina
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Peso da Disciplina',
                labelStyle: TextStyle(
                  color: Colors.deepPurple.shade700,
                ),
                hintText: 'Ex.: 40',
                helperText:
                    'Quanto essa disciplina vale dentro da prova (ex.: 40 pontos).',
                helperStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.deepPurple.shade400,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple.shade300),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Texto de ajuda adicional
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'O Peso da Disciplina indica sua importância dentro da prova. '
                'Posteriormente, os valores de “relativeImportance” e “globalImportance” '
                'serão recalculados de acordo com todos os pesos cadastrados.',
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

      // ------------------- Ações do Modal -------------------
      actions: [
        // Botão de Cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepPurple.shade600,
          ),
          child: const Text('Cancelar'),
        ),

        // Botão de Adicionar ou Indicador de Carregamento
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
                onPressed: _addSubject,
                child: const Text(
                  'Adicionar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ],
    );
  }
}
