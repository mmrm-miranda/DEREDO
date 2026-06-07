import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import '../home/models/feature_item.dart';
import '../register/register_screen.dart';
import '../register_business/register_business_screen.dart';
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
      _goHome(data['id'] as String);
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHome(String userId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          location: 'Durango, Dgo.',
          features: const [
            FeatureItem(title: 'Mapa local', description: 'Negocios cerca de ti por categoría'),
            FeatureItem(title: 'Rutas de barrio', description: 'Recorre zonas comerciales únicas'),
            FeatureItem(title: 'Registro por voz', description: 'Registra tu negocio en 2 min'),
            FeatureItem(title: 'Productos locales', description: 'Artesanías, mezcal, antojitos'),
          ],
          onExplore: () {},
          onFeatureTap: (_) {},
          onRegisterBusiness: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterBusinessScreen(
                usuarioId: userId,
                businessTypes: const [
                  'Antojitos duranguenses',
                  'Taquería',
                  'Bebidas',
                  'Artesanías',
                  'Abarrotes',
                  'Panadería',
                  'Otro',
                ],
                onVoiceRegister: () {},
                onChatAssistant: () {},
              ),
            ),
          ),
        ),
      ),
    );
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
