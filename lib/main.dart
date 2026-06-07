import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/env.dart';
import 'config/gemini_service.dart';
import 'screens/chat_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/models/feature_item.dart';
import 'screens/register_business/register_business_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'core/providers/auth_provider.dart';
import 'screens/recommendations/recommendations_screen.dart';
import 'screens/register_business/business_assistant_chat_screen.dart';
import 'services/google_cloud_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Error inicializando Firebase: $e");
    debugPrint("Asegúrate de tener google-services.json o ejecutar flutterfire configure.");
  }

  await GeminiService().init();

  debugPrint("Gemini API Key: ${Env.geminiApiKey.isNotEmpty ? 'OK' : 'FALTA'}");
  debugPrint("Google Maps Key: ${Env.googleMapsApiKey.isNotEmpty ? 'OK' : 'FALTA'}");

  runApp(
    const ProviderScope(
      child: DeredoApp(),
    ),
  );
}

class DeredoApp extends ConsumerWidget {
  const DeredoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DEREDO',
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
      home: Builder(
        builder: (context) {
          return HomeScreen(
            location: 'Durango, Dgo.',
            features: const [
              FeatureItem(title: 'Gastronomía', description: 'Restaurantes y comida local'),
              FeatureItem(title: 'Servicios', description: 'Encuentra lo que necesitas'),
              FeatureItem(title: 'Turismo', description: 'Lugares históricos y paseos'),
              FeatureItem(title: 'Compras', description: 'Tiendas, mercados y más'),
            ],
            onExplore: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendationsScreen()));
            },
            onRegisterBusiness: () {
              final isLoggedIn = ref.read(authProvider);
              if (isLoggedIn) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterBusinessScreen(
                  usuarioId: '1', // Temporal o desde authProvider
                  businessTypes: const ['Restaurante/Comida', 'Tienda', 'Servicios', 'Artesanías', 'Otro'],
                  onVoiceRegister: () {},
                  onChatAssistant: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessAssistantChatScreen(usuarioId: '1')));
                  },
                )));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            onFeatureTap: (feature) {
              if (feature.title == 'Turismo') {
                showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                    backgroundColor: const Color(0xFFF5F0EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB84A1A).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.explore_outlined, color: Color(0xFFB84A1A), size: 36),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '¿Qué tipo de turismo buscas?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Elige una opción para descubrir experiencias increíbles.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
                              },
                              icon: const Icon(Icons.museum_outlined),
                              label: const Text('Lugar histórico', style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A7C6F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
                              },
                              icon: const Icon(Icons.nature_people_outlined),
                              label: const Text('Naturaleza', style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB84A1A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
                              },
                              icon: const Icon(Icons.directions_walk_outlined),
                              label: const Text('Paseo', style: TextStyle(fontSize: 16)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFB84A1A),
                                side: const BorderSide(color: Color(0xFFB84A1A), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
              }
            },
          );
        }
      ),
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
  bool _myLocationEnabled = false;
  StreamSubscription? _businessSub;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _listenToBusinesses();
  }

  void _listenToBusinesses() {
    // 1. Agregar marcadores simulados SIEMPRE, sin depender de Firebase
    final dummyMarkers = <Marker>{
      const Marker(
        markerId: MarkerId('sim_1'),
        position: LatLng(24.0280, -104.6530),
        infoWindow: InfoWindow(title: 'Café de Olla Durango', snippet: 'Restaurante/Comida'),
      ),
      const Marker(
        markerId: MarkerId('sim_2'),
        position: LatLng(24.0265, -104.6545),
        infoWindow: InfoWindow(title: 'Artesanías El Alacrán', snippet: 'Artesanías'),
      ),
      const Marker(
        markerId: MarkerId('sim_3'),
        position: LatLng(24.0290, -104.6520),
        infoWindow: InfoWindow(title: 'Gorditas Doña Ale', snippet: 'Restaurante/Comida'),
      ),
    };

    if (mounted) {
      setState(() {
        _markers.addAll(dummyMarkers);
      });
    }

    // 2. Intentar escuchar Firebase (envuelto en try-catch por si falla o no está configurado)
    try {
      _businessSub = FirebaseFirestore.instance.collection('businesses').snapshots().listen((snapshot) {
        final newMarkers = <Marker>{};
        newMarkers.addAll(dummyMarkers);

        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data['location'] != null && data['location'] is GeoPoint) {
            final loc = data['location'] as GeoPoint;
            newMarkers.add(Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(loc.latitude, loc.longitude),
              infoWindow: InfoWindow(
                title: data['name'] ?? 'Negocio',
                snippet: data['category_id'] ?? 'Local',
              ),
            ));
          }
        }
        if (mounted) {
          setState(() {
            _markers.clear();
            _markers.addAll(newMarkers);
          });
        }
      });
    } catch (e) {
      debugPrint("Firebase error ignorado para forzar que se vea el mapa: $e");
    }
  }

  @override
  void dispose() {
    _businessSub?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      
      if (mounted) {
        setState(() {
          _myLocationEnabled = true;
        });
      }

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          )
        ));
      }
    } catch (e) {
      debugPrint("Geolocator error in MapScreen: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: _myLocationEnabled,
            zoomControlsEnabled: false,
          ),
          // Top Search Bar Mock
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final isLoggedIn = ref.watch(authProvider);
                    return GestureDetector(
                      onTap: () {
                        if (!isLoggedIn) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        } else {
                          // Cerrar sesión
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: const Color(0xFFF5F0EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB84A1A).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.logout_rounded, color: Color(0xFFB84A1A), size: 36),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Cerrar sesión',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '¿Estás seguro que deseas salir de tu cuenta?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 28),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.black54,
                                              side: const BorderSide(color: Colors.black26),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              ref.read(authProvider.notifier).logout();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFB84A1A),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                            child: const Text('Salir', style: TextStyle(fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: isLoggedIn
                            ? ClipOval(child: Image.asset('assets/deredo.png', fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.person_outline)))
                            : const Icon(Icons.person_outline, color: Colors.black54),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
    );
  }
}
