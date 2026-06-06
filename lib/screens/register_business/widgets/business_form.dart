import 'package:flutter/material.dart';

class BusinessForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final String? selectedType;
  final List<String> businessTypes;
  final ValueChanged<String?> onTypeChanged;

  const BusinessForm({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.selectedType,
    required this.businessTypes,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nombre del comercio',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: _inputDecoration('Ej. Tortillería La Güera'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tipo de comercio',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedType,
            items: businessTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: onTypeChanged,
            decoration: _inputDecoration(null),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
          ),
          const SizedBox(height: 18),
          const Text(
            'Dirección',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: addressController,
            decoration: _inputDecoration('Calle, número, colonia').copyWith(
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                width: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196A6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.my_location, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDD8D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDD8D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF8B3A1A)),
      ),
    );
  }
}
