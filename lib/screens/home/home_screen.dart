import 'package:flutter/material.dart';
import 'models/feature_item.dart';
import 'widgets/home_header.dart';
import 'widgets/features_grid.dart';

class HomeScreen extends StatelessWidget {
  final String location;
  final List<FeatureItem> features;
  final VoidCallback onExplore;
  final VoidCallback onRegisterBusiness;
  final void Function(FeatureItem) onFeatureTap;

  const HomeScreen({
    super.key,
    required this.location,
    required this.features,
    required this.onExplore,
    required this.onRegisterBusiness,
    required this.onFeatureTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          HomeHeader(location: location),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  FeaturesGrid(
                    items: features,
                    onItemTap: onFeatureTap,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _HomeActions(
            onExplore: onExplore,
            onRegisterBusiness: onRegisterBusiness,
          ),
        ],
      ),
    );
  }
}

class _HomeActions extends StatelessWidget {
  final VoidCallback onExplore;
  final VoidCallback onRegisterBusiness;

  const _HomeActions({
    required this.onExplore,
    required this.onRegisterBusiness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0EB),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onExplore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB84A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Explorar negocios cercanos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: onRegisterBusiness,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB84A1A),
                side: const BorderSide(color: Color(0xFFB84A1A), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Registrar mi negocio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
