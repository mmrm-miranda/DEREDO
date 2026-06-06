import 'package:flutter/material.dart';

class VoiceLoginButton extends StatelessWidget {
  final VoidCallback onTap;

  const VoiceLoginButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFD9D9D9))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'acceso rápido',
                  style: TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFD9D9D9))),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF0F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB3D9EC), width: 1),
              ),
              child: Column(
                children: const [
                  Text(
                    'Iniciar con reconocimiento de voz',
                    style: TextStyle(
                      color: Color(0xFF1A6D99),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ideal si tienes dificultad con el teclado',
                    style: TextStyle(
                      color: Color(0xFF1A6D99),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
