import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Monta o body para mandar no POST (JSON)
      final body = {
        "name": _nameCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "password": _passwordCtrl.text.trim(),
        "exams": [] // se quiser já iniciar sem exams
      };

      // Faz a requisição para criar usuário (ajuste a URL conforme necessário)
      final url = Uri.parse('http://localhost:8080/api/users/create');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: encodeJson(body), // Precisaria de um import ou uso de jsonEncode
      );

      if (response.statusCode == 201) {
        // Sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário criado com sucesso!')),
        );
        // Navega de volta à tela de login, por exemplo
        Navigator.pop(context);
      } else {
        // Erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar usuário: ${response.body}')),
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

  // Se não tiver importado 'dart:convert' e usar `jsonEncode`, crie helper:
  String encodeJson(Map<String, dynamic> data) {
    return '{"name":"${data['name']}","email":"${data['email']}","password":"${data['password']}","exams":[]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradiente de fundo
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade600,
              Colors.deepPurple.shade100,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade50.withOpacity(0.4),
                      Colors.white.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Contadeiro',
                      style: TextStyle(
                        color: Colors.deepPurple.shade700,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Crie sua conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.deepPurple.shade700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo Nome
                    CustomTextField(
                      controller: _nameCtrl,
                      hintText: 'Nome',
                    ),
                    const SizedBox(height: 16),

                    // Campo Email
                    CustomTextField(
                      controller: _emailCtrl,
                      hintText: 'Email',
                    ),
                    const SizedBox(height: 16),

                    // Campo Senha
                    CustomTextField(
                      controller: _passwordCtrl,
                      hintText: 'Senha',
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    // Botão registrar
                    _isLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            text: 'Registrar',
                            onPressed: _register,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
