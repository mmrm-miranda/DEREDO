class ProductModel {
  final String emoji;
  final String name;
  final String description;
  final String price;

  const ProductModel({
    required this.emoji,
    required this.name,
    required this.description,
    required this.price,
  });
}

class ProductCategoryModel {
  final String name;
  final List<ProductModel> products;

  const ProductCategoryModel({
    required this.name,
    required this.products,
  });
}
