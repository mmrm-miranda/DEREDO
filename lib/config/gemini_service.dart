import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  static const _projectId = 'gen-lang-client-0483127667';
  static const _location = 'us-central1';
  static const _model = 'gemini-2.0-flash-001';
  static const _scopes = ['https://www.googleapis.com/auth/cloud-platform'];

  static const _systemPrompt =
      'Eres un asistente de la app DEREDO, una plataforma para descubrir negocios locales en Durango, México. '
      'Ayuda a los usuarios a encontrar negocios, recomendar lugares, y responder preguntas sobre la ciudad. '
      'Responde siempre en español de forma concisa y amigable.';

  http.Client? _authClient;
  final List<Map<String, dynamic>> _history = [];

  Future<void> init() async {
    final jsonStr = await rootBundle.loadString('gen-lang-client-0483127667-1062ab4ca253.json');
    final credentials = ServiceAccountCredentials.fromJson(jsonStr);
    _authClient = await clientViaServiceAccount(credentials, _scopes);
  }

  String get _endpoint =>
      'https://$_location-aiplatform.googleapis.com/v1/projects/$_projectId/locations/$_location/publishers/google/models/$_model:generateContent';

  Future<String> sendMessage(String message) async {
    if (_authClient == null) return 'Error: servicio no inicializado';

    _history.add({
      'role': 'user',
      'parts': [{'text': message}],
    });

    try {
      final body = jsonEncode({
        'system_instruction': {
          'parts': [{'text': _systemPrompt}],
        },
        'contents': _history,
      });

      final response = await _authClient!.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        _history.removeLast();
        final err = jsonDecode(response.body);
        return 'Error: ${err['error']?['message'] ?? response.statusCode}';
      }

      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
              as String? ??
          'Sin respuesta';

      _history.add({
        'role': 'model',
        'parts': [{'text': text}],
      });

      return text;
    } catch (e) {
      _history.removeLast();
      return 'Error al conectar con Gemini: $e';
    }
  }

  Future<String> askOnce(String prompt) async {
    if (_authClient == null) return 'Error: servicio no inicializado';

    try {
      final body = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': prompt}],
          }
        ],
      });

      final response = await _authClient!.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        final err = jsonDecode(response.body);
        return 'Error: ${err['error']?['message'] ?? response.statusCode}';
      }

      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text']
              as String? ??
          'Sin respuesta';
    } catch (e) {
      return 'Error al conectar con Gemini: $e';
    }
  }

  void dispose() {
    _authClient?.close();
  }
}
