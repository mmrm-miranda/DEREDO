import 'package:flutter/material.dart';
import '../../services/google_cloud_service.dart';
import '../products/products_screen.dart';
import '../products/models/product_model.dart';
import 'widgets/register_business_header.dart';
import 'widgets/voice_or_chat_card.dart';
import 'widgets/business_form.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RegisterBusinessScreen extends StatefulWidget {
  final String usuarioId;
  final List<String> businessTypes;
  final VoidCallback onVoiceRegister;
  final VoidCallback onChatAssistant;

  const RegisterBusinessScreen({
    super.key,
    required this.usuarioId,
    required this.businessTypes,
    required this.onVoiceRegister,
    required this.onChatAssistant,
  });

  @override
  State<RegisterBusinessScreen> createState() => _RegisterBusinessScreenState();
}

class _RegisterBusinessScreenState extends State<RegisterBusinessScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedType;
  bool _loading = false;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    if (widget.businessTypes.isNotEmpty) {
      _selectedType = widget.businessTypes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getLocationAddress() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Los servicios de ubicación están desactivados.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permisos de ubicación denegados.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente.');
      }

      Position position = await Geolocator.getCurrentPosition();
      _lat = position.latitude;
      _lng = position.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street ?? ''}, ${place.subLocality ?? place.locality ?? ''}';
        address = address.replaceAll(RegExp(r'^,\s*'), '').trim();
        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleContinue() async {
    final nombre = _nameController.text.trim();
    final direccion = _addressController.text.trim();
    if (nombre.isEmpty || direccion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre y dirección')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      if (_lat == null || _lng == null) {
        try {
          Position pos = await Geolocator.getCurrentPosition();
          _lat = pos.latitude;
          _lng = pos.longitude;
        } catch (_) {}
      }

      final data = await GoogleCloudService().crearNegocio(
        usuarioId: widget.usuarioId,
        nombre: nombre,
        tipo: _selectedType ?? '',
        direccion: direccion,
        lat: _lat,
        lng: _lng,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProductsScreen(
            negocioId: data['id'],
            businessName: nombre,
            businessSubtitle: '${_selectedType ?? ''} · $direccion',
            categories: const [],
            onAddProduct: () {},
            onPublish: () {},
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          const RegisterBusinessHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VoiceOrChatCard(
                    onVoice: widget.onVoiceRegister,
                    onChat: widget.onChatAssistant,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: const [
                        Expanded(child: Divider(indent: 16, color: Color(0xFFD9D9D9))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'o llena el formulario',
                            style: TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                        ),
                        Expanded(child: Divider(endIndent: 16, color: Color(0xFFD9D9D9))),
                      ],
                    ),
                  ),
                  BusinessForm(
                    nameController: _nameController,
                    addressController: _addressController,
                    selectedType: _selectedType,
                    businessTypes: widget.businessTypes,
                    onTypeChanged: (v) => setState(() => _selectedType = v),
                    onGetLocation: _getLocationAddress,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _ContinueButton(onPressed: _loading ? null : _handleContinue, loading: _loading),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const _ContinueButton({required this.onPressed, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0EB),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB84A1A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Continuar — Agregar productos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
