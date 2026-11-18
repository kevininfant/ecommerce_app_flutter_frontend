class OfferModel {
  final String id;
  final String title;
  final String description;
  final int discountPercent;
  final String code;
  final String imageUrl;
  final String expiresAt;
  final bool isActive;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercent,
    required this.code,
    required this.imageUrl,
    required this.expiresAt,
    required this.isActive,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map) => OfferModel(
        id: map['_id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        discountPercent: map['discountPercent'] ?? 0,
        code: map['code'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        expiresAt: map['expiresAt'] ?? '',
        isActive: map['isActive'] ?? true,
      );
}
