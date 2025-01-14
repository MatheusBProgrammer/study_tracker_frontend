import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    setState(() => _isLoading = true);
    try {
      // Monta o body para mandar no POST (JSON)
      final body = {
        "name": _nameCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "password": _passwordCtrl.text.trim(),
        "exams": [],
      };

      // Ajuste a URL conforme sua API
      final url = Uri.parse('http://localhost:8080/api/users/create');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: _encodeJson(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário criado com sucesso!')),
        );
        Navigator.pop(context); // Volta ao login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar usuário: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Se não quiser usar o 'dart:convert' (jsonEncode), pode serializar manualmente:
  String _encodeJson(Map<String, dynamic> data) {
    return '{"name":"${data['name']}","email":"${data['email']}","password":"${data['password']}","exams":[]}';
  }

  /// Voltar para a tela de Login
  void _goToLogin() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Mesmo fundo claro do Login
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Imagem do relógio
              Image.asset(
                'assets/images/watch.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 16),

              /// Título principal
              Text('Contadeiro',
                  style: GoogleFonts.montserrat(
                      fontSize: 28, color: const Color(0xFF9900CC))),
              const SizedBox(height: 16),

              /// Subtítulo
              Text(
                'Crie sua conta para continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),

              /// Campo: Nome
              CustomTextField(
                controller: _nameCtrl,
                hintText: 'Nome',
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Nome',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Campo: Email
              CustomTextField(
                controller: _emailCtrl,
                hintText: 'Email',
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Campo: Senha
              CustomTextField(
                controller: _passwordCtrl,
                hintText: 'Senha',
                obscureText: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Senha',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: const Color(0xFF9900CC),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Botão de registro ou indicador de carregamento
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Registrar',
                        onPressed: _register,
                        color: const Color(0xFF9900CC),
                        textColor: Colors.white,
                      ),
                    ),
              const SizedBox(height: 16),

              /// Link para voltar ao login
              GestureDetector(
                onTap: _goToLogin,
                child: Text(
                  'Já tem conta? Voltar ao Login',
                  style: TextStyle(
                    color: const Color(0xFF9900CC),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
