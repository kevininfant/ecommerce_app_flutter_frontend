class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String type;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.isActive,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map) => BannerModel(
        id: map['_id'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        title: map['title'] ?? '',
        subtitle: map['subtitle'] ?? '',
        type: map['type'] ?? 'slider',
        isActive: map['isActive'] ?? true,
      );

  Map<String, dynamic> toMap() => {
        'imageUrl': imageUrl,
        'title': title,
        'subtitle': subtitle,
        'type': type,
        'isActive': isActive,
      };
}
