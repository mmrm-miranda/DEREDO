import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../config/env.dart';
import '../../../services/google_cloud_service.dart';
import '../products/products_screen.dart';

import 'package:geolocator/geolocator.dart';

class BusinessAssistantChatScreen extends StatefulWidget {
  final String usuarioId;
  
  const BusinessAssistantChatScreen({super.key, required this.usuarioId});

  @override
  State<BusinessAssistantChatScreen> createState() => _BusinessAssistantChatScreenState();
}

class _BusinessAssistantChatScreenState extends State<BusinessAssistantChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  void _initChat() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: Env.geminiApiKey,
      systemInstruction: Content.system(
        'Eres un asistente amigable de la app DEREDO para ayudar a registrar un negocio local. '
        'Tu objetivo es recopilar 3 datos de forma conversacional y natural:\n'
        '1. Nombre del negocio\n'
        '2. Tipo de comercio (ej: Restaurante, Tienda, Servicios)\n'
        '3. Dirección del negocio (calle y colonia)\n\n'
        'Haz preguntas cortas. NO pidas los 3 datos al mismo tiempo en el primer mensaje. '
        'Inicia la conversación saludando y preguntando el nombre del negocio.\n'
        'Una vez que hayas recopilado los 3 datos, agradece, despídete y AL FINAL de tu último mensaje, debes incluir ESTRICTAMENTE un bloque JSON con los datos recopilados en este formato exacto:\n'
        '```json\n{"nombre": "...", "tipo": "...", "direccion": "..."}\n```'
      ),
    );
    _chat = _model.startChat();
    
    // Add the initial bot greeting message visually
    setState(() {
      _messages.add(_ChatMessage(text: '¡Hola! Soy tu asistente de DEREDO. Estoy aquí para ayudarte a registrar tu negocio de forma rápida. ¿Cómo se llama tu negocio?', isUser: false));
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      String rawText = response.text ?? 'Lo siento, no entendí eso.';
      String cleanedResponse = rawText;
      Map<String, dynamic>? businessData;

      if (rawText.contains('```json')) {
        try {
          final startIndex = rawText.indexOf('```json') + 7;
          final endIndex = rawText.indexOf('```', startIndex);
          final jsonStr = rawText.substring(startIndex, endIndex).trim();
          businessData = jsonDecode(jsonStr);
          cleanedResponse = rawText.substring(0, rawText.indexOf('```json')).trim();
        } catch (e) {
          debugPrint("Error parsing JSON: $e");
        }
      }

      setState(() {
        if (cleanedResponse.isNotEmpty) {
          _messages.add(_ChatMessage(text: cleanedResponse, isUser: false));
        }
        if (businessData == null) {
          _isLoading = false;
        }
      });
      _scrollToBottom();

      if (businessData != null) {
        // We have the data! Proceed to create business
        await _createBusiness(businessData);
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(text: 'Error de conexión: $e', isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _createBusiness(Map<String, dynamic> data) async {
    try {
      double? lat;
      double? lng;
      try {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {}

      final res = await GoogleCloudService().crearNegocio(
        usuarioId: widget.usuarioId,
        nombre: data['nombre'] ?? 'Negocio Sin Nombre',
        tipo: data['tipo'] ?? 'Desconocido',
        direccion: data['direccion'] ?? 'Dirección no proporcionada',
        lat: lat,
        lng: lng,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Negocio registrado automáticamente con éxito!'), backgroundColor: Colors.green),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProductsScreen(
            negocioId: res['id'],
            businessName: res['nombre'],
            businessSubtitle: '${data['tipo']} · ${data['direccion']}',
            categories: const [],
            onAddProduct: () {},
            onPublish: () {},
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar negocio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF2196A6);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: const Icon(Icons.support_agent, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asistente de Registro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('DEREDO AI', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator(color);
                return _buildBubble(_messages[index], color);
              },
            ),
          ),
          _buildInputBar(color),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg, Color color) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? color : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(color: color, delay: 0),
            const SizedBox(width: 4),
            _Dot(color: color, delay: 200),
            const SizedBox(width: 4),
            _Dot(color: color, delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(Color color) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Escribe tu respuesta...',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: color,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _Dot extends StatefulWidget {
  final Color color;
  final int delay;
  const _Dot({required this.color, required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: CircleAvatar(radius: 4, backgroundColor: widget.color),
    );
  }
}
