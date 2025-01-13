import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Ao logar com sucesso, vai para a Home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navega para a página de registro
  void _goToRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    // Podemos manter a cor de fundo e gradiente para toda a tela, de forma
    // coerente com seu estilo.
    return Scaffold(
      // Removemos o backgroundColor se quisermos usar gradiente direto no body
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
                  // Gradiente interno para o card (opcional)
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
                    // Nome do APP
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
                      'Bem-vindo(a)! Faça Login para continuar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.deepPurple.shade700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo de Email
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                    ),
                    const SizedBox(height: 16),

                    // Campo de Senha
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Senha',
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    // Botão Login ou indicador de carregando
                    _isLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            text: 'Entrar',
                            onPressed: _login,
                          ),
                    const SizedBox(height: 16),

                    // Link para criar conta
                    GestureDetector(
                      onTap: _goToRegister,
                      child: Text(
                        'Não tem conta? Registre-se',
                        style: TextStyle(
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
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
