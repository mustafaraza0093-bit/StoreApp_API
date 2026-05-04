class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.slug,
  });

  final int id;
  final String name;
  final String image;
  final String slug;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    required this.description,
    required this.category,
    required this.images,
  });

  final int id;
  final String title;
  final String slug;
  final double price;
  final String description;
  final ProductCategory? category;
  final List<String> images;

  String get primaryImage =>
      images.isNotEmpty ? images.first : '';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    ProductCategory? cat;
    final rawCat = json['category'];
    if (rawCat is Map<String, dynamic>) {
      cat = ProductCategory.fromJson(rawCat);
    }

    final imgs = <String>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final e in rawImages) {
        if (e is String) imgs.add(e);
      }
    }

    return ProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      price: _toDouble(json['price']),
      description: json['description'] as String? ?? '',
      category: cat,
      images: imgs,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
