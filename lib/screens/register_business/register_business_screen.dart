import 'package:flutter/material.dart';
import 'widgets/register_business_header.dart';
import 'widgets/voice_or_chat_card.dart';
import 'widgets/business_form.dart';

class RegisterBusinessScreen extends StatefulWidget {
  final List<String> businessTypes;
  final void Function({
    required String name,
    required String type,
    required String address,
  }) onContinue;
  final VoidCallback onVoiceRegister;
  final VoidCallback onChatAssistant;

  const RegisterBusinessScreen({
    super.key,
    required this.businessTypes,
    required this.onContinue,
    required this.onVoiceRegister,
    required this.onChatAssistant,
  });

  @override
  State<RegisterBusinessScreen> createState() => _RegisterBusinessScreenState();
}

class _RegisterBusinessScreenState extends State<RegisterBusinessScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.businessTypes.isNotEmpty) {
      _selectedType = widget.businessTypes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    widget.onContinue(
      name: _nameController.text.trim(),
      type: _selectedType ?? '',
      address: _addressController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          const RegisterBusinessHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VoiceOrChatCard(
                    onVoice: widget.onVoiceRegister,
                    onChat: widget.onChatAssistant,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: const [
                        Expanded(child: Divider(indent: 16, color: Color(0xFFD9D9D9))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'o llena el formulario',
                            style: TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                        ),
                        Expanded(child: Divider(endIndent: 16, color: Color(0xFFD9D9D9))),
                      ],
                    ),
                  ),
                  BusinessForm(
                    nameController: _nameController,
                    addressController: _addressController,
                    selectedType: _selectedType,
                    businessTypes: widget.businessTypes,
                    onTypeChanged: (v) => setState(() => _selectedType = v),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _ContinueButton(onPressed: _handleContinue),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0EB),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB84A1A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Continuar — Agregar productos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
