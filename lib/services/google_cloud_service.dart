import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class GoogleCloudService {
  static final GoogleCloudService _instance = GoogleCloudService._internal();
  factory GoogleCloudService() => _instance;
  GoogleCloudService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      // First, get all published businesses (since Firestore lacks native geospatial queries without GeoFlutterFire)
      final allPublished = await fetchPublishedBusinesses();
      
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
      
      return nearby;
    } catch (e) {
      throw Exception('Error al obtener negocios cercanos: $e');
    }
  }
}
