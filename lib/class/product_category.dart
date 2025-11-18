class ProductCategory {
  final int id;
  final String name;
  final String imageUrl; 

  ProductCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image'] as String,
    );
  }
}