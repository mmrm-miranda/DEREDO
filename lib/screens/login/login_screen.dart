import 'package:flutter/material.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/voice_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // TODO: implementar lógica de login
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    debugPrint('Login: $email / $password');
  }

  void _handleForgotPassword() {
    // TODO: navegar a pantalla de recuperar contraseña
  }

  void _handleRegister() {
    // TODO: navegar a pantalla de registro
  }

  void _handleVoiceLogin() {
    // TODO: iniciar flujo de reconocimiento de voz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LoginHeader(),
              LoginForm(
                emailController: _emailController,
                passwordController: _passwordController,
                onLogin: _handleLogin,
                onForgotPassword: _handleForgotPassword,
                onRegister: _handleRegister,
              ),
              VoiceLoginButton(onTap: _handleVoiceLogin),
            ],
          ),
        ),
      ),
    );
  }
}
