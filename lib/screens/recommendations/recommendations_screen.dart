import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/google_cloud_service.dart';
import '../chat_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  GoogleMapController? _mapController;
  final LatLng _defaultCenter = const LatLng(24.0277, -104.6532);
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _nearbyBusinesses = [];
  bool _loading = true;
  bool _myLocationEnabled = false;
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['Todos', 'Antojitos', 'Artesanías', 'Mezcal', 'Servicios'];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _determinePosition();
    await _fetchBusinesses();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setDefaultLocation();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultLocation();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _setDefaultLocation();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _myLocationEnabled = true;
        });
      }
    } catch (e) {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _userLocation = _defaultCenter;
        _myLocationEnabled = false;
      });
    }
  }

  Future<void> _fetchBusinesses() async {
    try {
      final loc = _userLocation ?? _defaultCenter;
      final businesses = await GoogleCloudService().fetchNearbyBusinesses(
        lat: loc.latitude,
        lng: loc.longitude,
        radiusKm: 10.0,
      );

      final Set<Marker> newMarkers = {};
      for (var business in businesses) {
        if (business['location'] is GeoPoint) {
          final GeoPoint geoPoint = business['location'] as GeoPoint;
          newMarkers.add(
            Marker(
              markerId: MarkerId(business['id'].toString()),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              infoWindow: InfoWindow(
                title: business['name'] ?? 'Negocio',
                snippet: business['address'] ?? '',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _nearbyBusinesses = businesses;
          _markers = newMarkers;
          _loading = false;
        });
        
        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: loc, zoom: 14.0),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF8B3A1A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('9:41', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              Text('Durango Centro', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  color: const Color(0xFFE8D5C8),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF8B3A1A)),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cerca de ti',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar negocio o producto...',
                hintStyle: TextStyle(color: Colors.white70),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB84A1A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFB84A1A) : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.30,
      child: _userLocation == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB84A1A)))
          : GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 14.5,
              ),
              markers: _markers,
              myLocationEnabled: _myLocationEnabled,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
    );
  }

  Widget _buildBusinessList() {
    return Expanded(
      child: Container(
        color: const Color(0xFFF5F0EB),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'Recomendados cerca de ti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFB84A1A)))
                  : _nearbyBusinesses.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron negocios cercanos.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80), // bottom padding for FAB
                          itemCount: _nearbyBusinesses.length,
                          itemBuilder: (context, index) {
                            final business = _nearbyBusinesses[index];
                            return _buildBusinessCard(business);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    final logoUrl = business['logo_url'];
    final name = business['name'] ?? 'Negocio';
    final desc = business['description'] ?? 'Descripción no disponible';
    final category = business['category_id'] ?? 'Categoría';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0EB),
              borderRadius: BorderRadius.circular(12),
              image: logoUrl != null
                  ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: logoUrl == null
                ? const Icon(Icons.storefront, color: Color(0xFFB84A1A), size: 30)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5C8).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF8B3A1A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '180 m', // Mock distance
                style: TextStyle(
                  color: Color(0xFF007A8C),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Text(
                    '4.8',
                    style: TextStyle(
                      color: Color(0xFF007A8C),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.star, color: Color(0xFF007A8C), size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          _buildMap(),
          _buildBusinessList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
        backgroundColor: const Color(0xFFE5B02E), // Yellow from the mock's bottom right button
        child: const Icon(Icons.smart_toy, color: Color(0xFF5A3A8A)), // Purple bot icon colors
      ),
    );
  }
}
