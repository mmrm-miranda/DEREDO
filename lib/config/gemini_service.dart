import 'package:google_generative_ai/google_generative_ai.dart';
import 'env.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late final GenerativeModel _model;
  late final ChatSession _chat;

  void init() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Env.geminiApiKey,
      systemInstruction: Content.system(
        'Eres un asistente de la app DEREDO, una plataforma para descubrir negocios locales en Durango, México. '
        'Ayuda a los usuarios a encontrar negocios, recomendar lugares, y responder preguntas sobre la ciudad. '
        'Responde siempre en español de forma concisa y amigable.',
      ),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'Sin respuesta';
    } catch (e) {
      return 'Error al conectar con Gemini: $e';
    }
  }

  Future<String> askOnce(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sin respuesta';
    } catch (e) {
      return 'Error al conectar con Gemini: $e';
    }
  }
}
