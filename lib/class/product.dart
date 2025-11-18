class Product {
  final int id;
  final String name;
  final int price;
  final String description;
  final String image;
  final List<int> categIds;
  final bool published;
  final List<int> optionalProductIds;
  final List<int> productImageIds;
  final List<String> images;
  final List<String> categories;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.categIds,
    required this.published,
    required this.optionalProductIds,
    required this.productImageIds,
    required this.images,
    required this.categories,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<T> safeListParse<T>(dynamic list) {
      if (list is List) {
        return list.where((e) => e != null).map((e) => e as T).toList();
      }
      return [];
    }

    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: json['list_price'] as int? ?? 0,
      description: json['description_ecommerce'] as String? ?? '',
      image: json['image_url'] as String? ?? '',
      published: json['website_published'] as bool? ?? false,
      categIds: safeListParse<int>(json['public_categ_ids']),
      optionalProductIds: safeListParse<int>(json['optional_product_ids']),
      productImageIds: safeListParse<int>(json['product_template_image_ids']),
      images: safeListParse<String>(json['images']),
      categories: safeListParse<String>(json['categories']),
    );
  }
}
