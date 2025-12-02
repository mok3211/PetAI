class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int priceCents;
  final int stock;
  ProductModel({required this.id, required this.name, this.description, this.imageUrl, required this.priceCents, required this.stock});
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      priceCents: map['price_cents'] as int,
      stock: map['stock'] as int,
    );
  }
}

