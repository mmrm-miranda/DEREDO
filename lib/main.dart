import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase. Requires flutterfire configure to be run first.
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed or not configured yet: $e");
  }

  runApp(
    const ProviderScope(
      child: DeredoApp(),
    ),
  );
}

class DeredoApp extends StatelessWidget {
  const DeredoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEREDO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35), // The color from the architecture
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? mapController;

  final LatLng _center = const LatLng(24.0277, -104.6532); // Durango coordinates from architecture
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      const Marker(
        markerId: MarkerId('mock_1'),
        position: LatLng(24.0280, -104.6530),
        infoWindow: InfoWindow(title: 'Gorditas Doña Mary', snippet: 'Antojitos Duranguenses'),
      ),
    );
    _markers.add(
      const Marker(
        markerId: MarkerId('mock_2'),
        position: LatLng(24.0265, -104.6545),
        infoWindow: InfoWindow(title: 'Tacos El Paisa', snippet: 'Taquería'),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 14.0,
              ),
              markers: _markers,
              myLocationEnabled: false, // Set to false until runtime permissions are requested
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          // Top Search Bar Mock
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar negocios locales...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open bottom sheet for category filters
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.filter_list, color: Colors.white),
      ),
    );
  }
}
