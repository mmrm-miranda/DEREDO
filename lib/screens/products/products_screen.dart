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
                        AddProductButton(onTap: widget.onAddProduct),
                      ],
                    ),
                  ),
          ),
          _PublishButton(onPublish: widget.onPublish),
        ],
      ),
    );
  }
}

class _PublishButton extends StatelessWidget {
  final VoidCallback onPublish;

  const _PublishButton({required this.onPublish});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0EB),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onPublish,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB84A1A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Text('Publicar mi negocio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
