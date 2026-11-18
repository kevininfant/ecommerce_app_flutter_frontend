import 'dart:convert';

class Order {
  final String id;
  final List<dynamic> products;
  final double totalPrice;
  final String address;
  final String userId;
  final String userName;
  final String userEmail;
  final String paymentMethod;
  final String paymentStatus;
  final int orderedAt;
  final int status;

  Order({
    required this.id,
    required this.products,
    required this.totalPrice,
    required this.address,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderedAt,
    required this.status,
  });

  factory Order.fromMap(Map<String, dynamic> map) => Order(
        id: map['_id'] ?? '',
        products: map['products'] ?? [],
        totalPrice: (map['totalPrice'] as num).toDouble(),
        address: map['address'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        userEmail: map['userEmail'] ?? '',
        paymentMethod: map['paymentMethod'] ?? 'COD',
        paymentStatus: map['paymentStatus'] ?? 'Pending',
        orderedAt: map['orderedAt'] ?? 0,
        status: map['status'] ?? 0,
      );

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  static String statusLabel(int s) {
    switch (s) {
      case 0: return 'Order Placed';
      case 1: return 'Processing';
      case 2: return 'Shipped';
      case 3: return 'Delivered';
      default: return 'Unknown';
    }
  }
}
