import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // Mapas y Rutas
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get orsApiKey => dotenv.env['ORS_API_KEY'] ?? '';

  // Gemini AI
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Vertex AI
  static String get vertexProjectId => dotenv.env['VERTEX_PROJECT_ID'] ?? '';
  static String get vertexLocation => dotenv.env['VERTEX_LOCATION'] ?? '';
  static String get googleAppCredentials =>
      dotenv.env['GOOGLE_APPLICATION_CREDENTIALS'] ?? '';
  static String get vertexImagenModel =>
      dotenv.env['VERTEX_IMAGEN_MODEL'] ?? '';
  static String get vertexVeoModel => dotenv.env['VERTEX_VEO_MODEL'] ?? '';

  // Cloud SQL / API
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get dbHost => dotenv.env['DB_HOST'] ?? '';
  static String get dbPort => dotenv.env['DB_PORT'] ?? '5432';
  static String get dbName => dotenv.env['DB_NAME'] ?? '';
  static String get dbUser => dotenv.env['DB_USER'] ?? '';
  static String get dbPassword => dotenv.env['DB_PASSWORD'] ?? '';

  // Google OAuth2
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get googleClientSecret =>
      dotenv.env['GOOGLE_CLIENT_SECRET'] ?? '';
  static String get googleCallbackUrl =>
      dotenv.env['GOOGLE_CALLBACK_URL'] ?? '';
}
