import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(24.0277, -104.6532);
  Set<Marker> _markers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNegocios();
  }

  Future<void> _loadNegocios() async {
    try {
      final negocios = await ApiService().listarNegocios();
      final markers = <Marker>{};
      for (final n in negocios) {
        if (n['lat'] != null && n['lng'] != null) {
          markers.add(Marker(
            markerId: MarkerId(n['id']),
            position: LatLng((n['lat'] as num).toDouble(), (n['lng'] as num).toDouble()),
            infoWindow: InfoWindow(title: n['nombre'], snippet: n['tipo']),
          ));
        }
      }
      if (mounted) setState(() => _markers = markers);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (c) => _mapController = c,
            initialCameraPosition: CameraPosition(target: _center, zoom: 14.0),
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF4A7C6F),
              padding: const EdgeInsets.only(top: 44, bottom: 12, left: 8, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Negocios en Durango',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
        backgroundColor: const Color(0xFF4A7C6F),
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
    );
  }
}
