import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'models/product_model.dart';
import 'widgets/products_header.dart';
import 'widgets/business_info_bar.dart';
import 'widgets/product_category_section.dart';
import 'widgets/add_product_button.dart';

class ProductsScreen extends StatefulWidget {
  final String negocioId;
  final String businessName;
  final String businessSubtitle;
  final List<ProductCategoryModel> categories;
  final VoidCallback onAddProduct;
  final VoidCallback onPublish;

  const ProductsScreen({
    super.key,
    required this.negocioId,
    required this.businessName,
    required this.businessSubtitle,
    required this.categories,
    required this.onAddProduct,
    required this.onPublish,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductCategoryModel> _categories = [];
  bool _loading = true;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _categories = widget.categories;
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    try {
      final data = await ApiService().listarCategorias(widget.negocioId);
      setState(() {
        _categories = data.map((cat) {
          final productos = (cat['productos'] as List).map((p) => ProductModel(
            emoji: p['emoji'] ?? '',
            name: p['nombre'],
            description: p['descripcion'] ?? '',
            price: p['precio'],
          )).toList();
          return ProductCategoryModel(name: cat['nombre'], products: productos);
        }).toList();
      });
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showAddDialog() async {
    await showDialog(
      context: context,
      builder: (_) => _AddProductDialog(
        negocioId: widget.negocioId,
        onSaved: _loadCategorias,
      ),
    );
  }

  Future<void> _handlePublish() async {
    setState(() => _publishing = true);
    try {
      await ApiService().publicarNegocio(widget.negocioId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Negocio publicado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          const ProductsHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BusinessInfoBar(
                          name: widget.businessName,
                          subtitle: widget.businessSubtitle,
                        ),
                        for (final cat in _categories)
                          ProductCategorySection(category: cat),
                        AddProductButton(onTap: _showAddDialog),
                      ],
                    ),
                  ),
          ),
          _PublishButton(onPublish: _handlePublish, loading: _publishing),
        ],
      ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  final String negocioId;
  final VoidCallback onSaved;

  const _AddProductDialog({required this.negocioId, required this.onSaved});

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _catController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _emojiController = TextEditingController();
  bool _loading = false;
  String? _selectedCatId;
  List<Map<String, dynamic>> _existingCats = [];

  @override
  void initState() {
    super.initState();
    _loadCats();
  }

  Future<void> _loadCats() async {
    try {
      final data = await ApiService().listarCategorias(widget.negocioId);
      setState(() {
        _existingCats = data.map<Map<String, dynamic>>((c) => {'id': c['id'], 'nombre': c['nombre']}).toList();
        if (_existingCats.isNotEmpty) _selectedCatId = _existingCats.first['id'];
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    final catName = _catController.text.trim();
    final prodName = _nameController.text.trim();
    final precio = _priceController.text.trim();

    if (prodName.isEmpty || precio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y precio son obligatorios')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      String catId;
      if (catName.isNotEmpty) {
        final cat = await ApiService().crearCategoria(negocioId: widget.negocioId, nombre: catName);
        catId = cat['id'];
      } else if (_selectedCatId != null) {
        catId = _selectedCatId!;
      } else {
        final cat = await ApiService().crearCategoria(negocioId: widget.negocioId, nombre: 'General');
        catId = cat['id'];
      }
      await ApiService().crearProducto(
        categoriaId: catId,
        nombre: prodName,
        precio: precio,
        emoji: _emojiController.text.trim().isEmpty ? null : _emojiController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _catController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar producto', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_existingCats.isNotEmpty) ...[
              const Text('Categoría existente', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _selectedCatId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _existingCats.map((c) => DropdownMenuItem<String>(
                  value: c['id'] as String,
                  child: Text(c['nombre'] as String),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCatId = v),
              ),
              const SizedBox(height: 8),
              const Text('— o crea una nueva —', style: TextStyle(fontSize: 11, color: Colors.black38)),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _catController,
              decoration: InputDecoration(
                labelText: 'Nueva categoría (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emojiController,
              decoration: InputDecoration(
                labelText: 'Emoji (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del producto *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Precio *',
                prefixText: '\$',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB84A1A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

class _PublishButton extends StatelessWidget {
  final VoidCallback onPublish;
  final bool loading;

  const _PublishButton({required this.onPublish, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0EB),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: loading ? null : onPublish,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB84A1A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Publicar mi negocio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
