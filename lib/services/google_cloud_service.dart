import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class GoogleCloudService {
  static final GoogleCloudService _instance = GoogleCloudService._internal();
  factory GoogleCloudService() => _instance;
  GoogleCloudService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAllBusinesses() async {
    try {
      final snapshot = await _firestore.collection('businesses').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Error al obtener todos los negocios: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPublishedBusinesses() async {
    try {
      final snapshot = await _firestore
          .collection('businesses')
          .where('is_published', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Error al obtener negocios: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNearbyBusinesses({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      // For the demo, get all businesses regardless of is_published
      final allPublished = await fetchAllBusinesses();
      
      final List<Map<String, dynamic>> nearby = [];
      
      for (var business in allPublished) {
        if (business['location'] is GeoPoint) {
          final GeoPoint loc = business['location'] as GeoPoint;
          final double distanceInMeters = Geolocator.distanceBetween(
            lat, lng, loc.latitude, loc.longitude
          );
          
          if (distanceInMeters <= (radiusKm * 1000)) {
            nearby.add(business);
          }
        }
      }
      
      // Agregar negocios simulados para la demostración
      nearby.addAll([
        {
          'id': 'sim_1',
          'name': 'Café de Olla Durango',
          'description': 'El mejor café tradicional y pan dulce.',
          'category_id': 'Restaurante/Comida',
          'address': 'Calle Constitución 123, Centro',
          'location': const GeoPoint(24.0280, -104.6530),
          'logo_url': null,
        },
        {
          'id': 'sim_2',
          'name': 'Artesanías El Alacrán',
          'description': 'Recuerdos y manualidades locales.',
          'category_id': 'Artesanías',
          'address': 'Mercado Gómez Palacio',
          'location': const GeoPoint(24.0265, -104.6545),
          'logo_url': null,
        },
        {
          'id': 'sim_3',
          'name': 'Gorditas Doña Ale',
          'description': 'Gorditas rellenas de guisos típicos.',
          'category_id': 'Restaurante/Comida',
          'address': 'Av. 20 de Noviembre 500',
          'location': const GeoPoint(24.0290, -104.6520),
          'logo_url': null,
        },
      ]);
      
      return nearby;
    } catch (e) {
      throw Exception('Error al obtener negocios cercanos: $e');
    }
  }
  Future<Map<String, dynamic>> crearNegocio({
    required String usuarioId,
    required String nombre,
    required String tipo,
    required String direccion,
    double? lat,
    double? lng,
  }) async {
    try {
      final docRef = await _firestore.collection('businesses').add({
        'usuario_id': usuarioId,
        'name': nombre,
        'category_id': tipo,
        'address': direccion,
        'location': (lat != null && lng != null) ? GeoPoint(lat, lng) : null,
        'is_published': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      return {
        'id': docRef.id,
        'nombre': nombre,
      };
    } catch (e) {
      throw Exception('Error al crear negocio: $e');
    }
  }
}
