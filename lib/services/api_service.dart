import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get _base => Env.apiBaseUrl;

  Future<Map<String, dynamic>> registro({
    required String correo,
    required String password,
    String nombre = '',
  }) async {
    final res = await http.post(
      Uri.parse('$_base/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'password': password, 'nombre': nombre}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'password': password}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> crearNegocio({
    required String usuarioId,
    required String nombre,
    required String tipo,
    required String direccion,
    double? lat,
    double? lng,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/negocios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_id': usuarioId,
        'nombre': nombre,
        'tipo': tipo,
        'direccion': direccion,
        'lat': lat,
        'lng': lng,
      }),
    );
    return _parse(res);
  }

  Future<List<dynamic>> listarNegocios() async {
    final res = await http.get(Uri.parse('$_base/negocios'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  Future<List<dynamic>> listarCategorias(String negocioId) async {
    final res = await http.get(Uri.parse('$_base/negocios/$negocioId/categorias'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  Future<Map<String, dynamic>> crearCategoria({
    required String negocioId,
    required String nombre,
    int orden = 0,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/negocios/$negocioId/categorias'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre, 'orden': orden}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> crearProducto({
    required String categoriaId,
    required String nombre,
    required String precio,
    String? emoji,
    String? descripcion,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/categorias/$categoriaId/productos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'precio': precio,
        'emoji': emoji,
        'descripcion': descripcion,
      }),
    );
    return _parse(res);
  }

  Future<void> publicarNegocio(String negocioId) async {
    final res = await http.patch(
      Uri.parse('$_base/negocios/$negocioId/publicar'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Error al publicar');
    }
  }

  Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body['error'] ?? 'Error desconocido');
  }
}
