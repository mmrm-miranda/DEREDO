import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import '../home/models/feature_item.dart';
import '../register/register_screen.dart';
import '../register_business/register_business_screen.dart';
import '../recommendations/recommendations_screen.dart';
import '../chat_screen.dart';
import '../map_screen.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/voice_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final correo = _emailController.text.trim();
    final password = _passwordController.text;
    if (correo.isEmpty || password.isEmpty) {
      _showError('Ingresa correo y contraseña');
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await ApiService().login(correo: correo, password: password);
      if (!mounted) return;
      await ref.read(authProvider.notifier).login();
      _goHome(data['id'] as String);
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHome(String userId) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
    );
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
                onLogin: _loading ? () {} : _handleLogin,
                onForgotPassword: () {},
                onRegister: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),
              VoiceLoginButton(onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
