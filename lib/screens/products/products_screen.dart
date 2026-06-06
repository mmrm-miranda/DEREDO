import 'package:flutter/material.dart';
import 'models/product_model.dart';
import 'widgets/products_header.dart';
import 'widgets/business_info_bar.dart';
import 'widgets/product_category_section.dart';
import 'widgets/add_product_button.dart';

class ProductsScreen extends StatelessWidget {
  final String businessName;
  final String businessSubtitle;
  final List<ProductCategoryModel> categories;
  final VoidCallback onAddProduct;
  final VoidCallback onPublish;

  const ProductsScreen({
    super.key,
    required this.businessName,
    required this.businessSubtitle,
    required this.categories,
    required this.onAddProduct,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          const ProductsHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BusinessInfoBar(
                    name: businessName,
                    subtitle: businessSubtitle,
                  ),
                  for (final cat in categories)
                    ProductCategorySection(category: cat),
                  AddProductButton(onTap: onAddProduct),
                ],
              ),
            ),
          ),
          _PublishButton(onPublish: onPublish),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Publicar mi negocio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
