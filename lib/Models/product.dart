import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int quantity;
  final double price;
  final String category;
  final List<Map<String, dynamic>> rating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.quantity,
    required this.price,
    required this.category,
    this.rating = const [],
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      quantity: map['quantity'] ?? 0,
      price: (map['price'] as num).toDouble(),
      category: map['category'] ?? '',
      rating: List<Map<String, dynamic>>.from(
          (map['rating'] as List? ?? []).map((r) => Map<String, dynamic>.from(r))),
    );
  }

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));

  Map<String, dynamic> toMap() => {
        '_id': id,
        'name': name,
        'description': description,
        'images': images,
        'quantity': quantity,
        'price': price,
        'category': category,
        'rating': rating,
      };

  String toJson() => json.encode(toMap());
}
