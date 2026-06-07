import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../login/login_screen.dart';

class HomeHeader extends StatelessWidget {
  final String location;

  const HomeHeader({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF4A7C6F),
      padding: const EdgeInsets.only(top: 52, bottom: 36, left: 20, right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final isLoggedIn = ref.watch(authProvider);
                  return GestureDetector(
                    onTap: () {
                      if (!isLoggedIn) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      } else {
                        ref.read(authProvider.notifier).logout();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isLoggedIn ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isLoggedIn ? null : Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: isLoggedIn
                          ? ClipOval(child: Image.asset('assets/deredo.png', fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.person_outline, color: Colors.black)))
                          : const Icon(Icons.person_outline, color: Colors.white),
                    ),
                  );
                },
              ),
              Text(
                location,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/deredo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A7C6F),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Deredo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '¿Te reborujaste vete por deredo?',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
